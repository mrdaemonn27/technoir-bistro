<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservation;
use App\Models\Table; 
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http; // <-- PENTING UNTUK API XENDIT

class ReservationController extends Controller
{
    // ========================================================
    // 1. FUNGSI UNTUK ADMIN: MELIHAT SEMUA RESERVASI
    // ========================================================
    public function index()
    {
        try {
            $reservations = Reservation::with(['user', 'table'])
                                     ->orderBy('created_at', 'desc')
                                     ->get();

            return response()->json([
                'success' => true,
                'data' => $reservations
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat daftar reservasi: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 2. FUNGSI UNTUK ADMIN: MENGUBAH STATUS RESERVASI
    // ========================================================
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:Pending,Confirmed,Completed,Cancelled'
        ]);

        try {
            $reservation = Reservation::find($id);

            if (!$reservation) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data reservasi tidak ditemukan'
                ], 404);
            }

            $reservation->status = $request->status;
            $reservation->save();

            return response()->json([
                'success' => true,
                'message' => 'Status berhasil diubah menjadi ' . $request->status,
                'data' => $reservation
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui status: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 3. FUNGSI UNTUK USER: MEMBUAT RESERVASI BARU & XENDIT INVOICE
    // ========================================================
    public function store(Request $request)
    {
        $request->validate([
            'reservation_date' => 'required|date',
            'reservation_time' => 'required',
            'guests' => 'required|string',
        ]);

        try {
            $guestsCount = (int) filter_var($request->guests, FILTER_SANITIZE_NUMBER_INT);
            if ($guestsCount == 0) $guestsCount = 1;

            $table = Table::first();
            $tableId = $table ? $table->id : 1; 
            
            $totalPrice = $request->total_price ?? 0;

            // 1. Simpan ke Database
            $reservation = Reservation::create([
                'user_id' => $request->user()->id,
                'table_id' => $tableId, 
                'reservation_date' => $request->reservation_date,
                'reservation_time' => $request->reservation_time,
                'guest_count' => $guestsCount, 
                'notes' => $request->notes, 
                'status' => 'Pending', 
                'total_price' => $totalPrice, 
            ]);

            // ==========================================================
            // 2. INTEGRASI XENDIT API (MEMBUAT INVOICE)
            // ==========================================================
            
            // ---> GANTI TULISAN DI BAWAH INI DENGAN KUNCI XENDIT ANDA <---
            $xenditSecretKey = 'xnd_development_SLPkxQk7sdUShrPbUvoOM8jWiHfuJtIF6Zsxa7tORIVopVlRUT04IaPHk5Z4Dz'; 
            
            // Buat ID unik untuk tagihan ini
            $externalId = 'TECHNOIR-' . $reservation->id . '-' . time();

            // Tembak API Xendit
            $response = Http::withBasicAuth($xenditSecretKey, '')
                ->post('https://api.xendit.co/v2/invoices', [
                    'external_id' => $externalId,
                    'amount' => $totalPrice,
                    'description' => 'Pembayaran Reservasi Technoir Bistro',
                    'customer' => [
                        'given_names' => $request->user()->username,
                        'email' => $request->user()->email,
                    ],
                    // URL dummy ini akan ditangkap di Flutter sebagai tanda sukses
                    'success_redirect_url' => 'https://technoirbistro.com/success', 
                    'failure_redirect_url' => 'https://technoirbistro.com/failure',
                ]);

            $xenditData = $response->json();
            $invoiceUrl = $xenditData['invoice_url'] ?? null;

            return response()->json([
                'success' => true,
                'message' => 'Reservasi & Invoice berhasil dibuat',
                'data' => $reservation,
                'invoice_url' => $invoiceUrl // Kirim URL pembayaran ke Flutter
            ], 201);

        } catch (\Exception $e) {
            Log::error('Error Booking API: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal booking: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 4. FUNGSI UNTUK USER: MELIHAT RIWAYAT RESERVASI SENDIRI
    // ========================================================
    public function userHistory(Request $request)
    {
        try {
            $reservations = Reservation::where('user_id', $request->user()->id)
                                     ->orderBy('created_at', 'desc')
                                     ->get();

            return response()->json([
                'success' => true,
                'data' => $reservations
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat riwayat: ' . $e->getMessage()
            ], 500);
        }
    }

    // ========================================================
    // 5. FUNGSI UNTUK USER: MENDAPATKAN NOTIFIKASI
    // ========================================================
    public function notifications(Request $request)
    {
        try {
            $user = $request->user();
            
            // Ambil reservasi user beserta data pembayaran terkait
            $reservations = Reservation::where('user_id', $user->id)
                ->with('payment')
                ->orderBy('updated_at', 'desc')
                ->take(15) // Ambil 15 aktivitas terakhir agar loading cepat
                ->get();

            $notifications = [];

            foreach ($reservations as $res) {
                // 1. Cek Notifikasi Pembayaran Berhasil (Misalnya dari Xendit Webhook)
                if ($res->payment && $res->payment->payment_status === 'verified') {
                    $notifications[] = [
                        'id' => 'pay_' . $res->payment->id,
                        'title' => 'Pembayaran Berhasil 🎉',
                        'message' => 'Pembayaran sebesar Rp ' . number_format($res->payment->amount, 0, ',', '.') . ' untuk Order #' . $res->id . ' telah diverifikasi oleh sistem Xendit.',
                        'time' => $res->payment->updated_at->diffForHumans(),
                        'timestamp' => $res->payment->updated_at,
                        'icon' => 'payment'
                    ];
                }

                // 2. Cek Notifikasi Status Reservasi Dikonfirmasi
                if ($res->status === 'Confirmed') {
                    $notifications[] = [
                        'id' => 'res_conf_' . $res->id,
                        'title' => 'Reservasi Dikonfirmasi ✅',
                        'message' => 'Hore! Reservasi meja Anda untuk tanggal ' . \Carbon\Carbon::parse($res->reservation_date)->format('d M Y') . ' jam ' . $res->reservation_time . ' telah dikonfirmasi admin.',
                        'time' => $res->updated_at->diffForHumans(),
                        'timestamp' => $res->updated_at,
                        'icon' => 'confirmed'
                    ];
                } 
                // 3. Cek Notifikasi Status Reservasi Dibatalkan
                elseif ($res->status === 'Cancelled') {
                    $notifications[] = [
                        'id' => 'res_canc_' . $res->id,
                        'title' => 'Reservasi Dibatalkan ❌',
                        'message' => 'Mohon maaf, reservasi Order #' . $res->id . ' Anda telah dibatalkan.',
                        'time' => $res->updated_at->diffForHumans(),
                        'timestamp' => $res->updated_at,
                        'icon' => 'cancelled'
                    ];
                }
                // 4. Cek Notifikasi Menunggu Konfirmasi (Pending)
                elseif ($res->status === 'Pending') {
                    $notifications[] = [
                        'id' => 'res_pend_' . $res->id,
                        'title' => 'Menunggu Konfirmasi ⏳',
                        'message' => 'Pesanan #' . $res->id . ' telah diterima. Jika Anda sudah membayar via Xendit, mohon tunggu admin mengonfirmasi pesanan Anda.',
                        'time' => $res->created_at->diffForHumans(),
                        'timestamp' => $res->created_at,
                        'icon' => 'pending'
                    ];
                }
            }

            // Urutkan array notifikasi berdasarkan waktu terbaru
            usort($notifications, function ($a, $b) {
                return $b['timestamp'] <=> $a['timestamp'];
            });

            return response()->json([
                'success' => true,
                'data' => $notifications
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memuat notifikasi: ' . $e->getMessage()
            ], 500);
        }
    }
}
<?php

namespace App\Http\Controllers;

use App\Models\Reservation;
use App\Models\Table;
use App\Models\Menu;
use App\Models\Favorite;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReservationController extends Controller
{
    /**
     * Menampilkan daftar reservasi milik user yang sedang login.
     */
    public function index()
    {
        // PERBAIKAN: Menggunakan latest() (alias untuk order by created_at)
        // karena kolom 'reservation_date' menyebabkan error "Column not found".
        $reservations = Reservation::where('user_id', Auth::id())
                        ->with(['table', 'menus', 'payment']) // Load payment juga
                        ->latest() 
                        ->get();

        return view('reservations.index', compact('reservations'));
    }

    /**
     * Menampilkan form untuk membuat reservasi baru.
     */
    public function create()
    {
        $tables = Table::where('status', 'available')->get();
        // (FR-06) Ambil semua menu yang tersedia agar bisa dipilih di form (Pre-order)
        $menus = Menu::where('availability', true)->get();

        // Ambil menu favorit user (jika login)
        $favoriteMenuIds = Favorite::where('user_id', Auth::id())
            ->pluck('menu_id')
            ->toArray();

        return view('reservations.create', [
            'tables' => $tables,
            'menus' => $menus,
            'favoriteMenuIds' => $favoriteMenuIds,
        ]);
    }

    /**
     * Menyimpan data reservasi dan pesanan menu ke database.
     */
    public function store(Request $request)
    {
        $request->validate([
            'reservation_date' => [
                'required',
                'date',
                'after:now',
                function ($attribute, $value, $fail) {
                    $date = Carbon::parse($value);
                    if ($date->minute !== 0) {
                        $fail('Waktu reservasi harus jam genap (contoh: 12:00, 13:00, 14:00).');
                    }
                },
            ],
            'table_id' => 'required|exists:tables,id',
            'guest_count' => 'required|integer|min:1',
            'notes' => 'nullable|string',
            'menus' => 'nullable|array',
            'menus.*' => 'integer|min:0'
        ]);

        // CATATAN: Pastikan Anda sudah membuat migrasi untuk menambah kolom 'reservation_date'
        // ke tabel 'reservations'. Jika belum, fungsi store ini akan error saat submit form.
        $reservation = Reservation::create([
            'user_id' => Auth::id(),
            'table_id' => $request->table_id,
            'reservation_date' => $request->reservation_date,
            'guest_count' => $request->guest_count,
            'status' => 'pending',
            'notes' => $request->notes,
        ]);

        if ($request->has('menus')) {
            foreach ($request->menus as $menuId => $quantity) {
                if ($quantity > 0) {
                    $reservation->menus()->attach($menuId, ['quantity' => $quantity]);
                }
            }
        }

        // --- UPDATE FR-02: Redirect ke Halaman Pembayaran ---
        // Alih-alih ke index, kita arahkan ke payments.create dengan membawa ID reservasi
        return redirect()->route('payments.create', ['reservation_id' => $reservation->id])
                         ->with('success', 'Reservasi berhasil dibuat! Langkah selanjutnya: Upload Bukti Pembayaran.');
    }

    /**
     * (FR-08) Menampilkan form edit reservasi.
     */
    public function edit(Reservation $reservation)
    {
        // 1. Pastikan yang edit adalah pemilik reservasi
        if ($reservation->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        // 2. Jangan izinkan edit jika status sudah selesai/batal
        if (in_array($reservation->status, ['completed', 'cancelled'])) {
            return redirect()->route('reservations.index')
                             ->with('error', 'Reservasi yang sudah selesai atau dibatalkan tidak dapat diubah.');
        }

        // Ambil semua meja
        $tables = Table::all();
        $menus = Menu::where('availability', true)->get();

        return view('reservations.edit', compact('reservation', 'tables', 'menus'));
    }

    /**
     * (FR-08) Menyimpan perubahan reservasi.
     */
    public function update(Request $request, Reservation $reservation)
    {
        // 1. Cek kepemilikan
        if ($reservation->user_id !== Auth::id()) {
            abort(403);
        }

        // 2. Validasi
        $request->validate([
            'reservation_date' => [
                'required',
                'date',
                'after:now',
                function ($attribute, $value, $fail) {
                    $date = Carbon::parse($value);
                    if ($date->minute !== 0) {
                        $fail('Waktu reservasi harus jam genap (contoh: 12:00, 13:00, 14:00).');
                    }
                },
            ],
            'table_id' => 'required|exists:tables,id',
            'guest_count' => 'required|integer|min:1',
            'notes' => 'nullable|string',
            'menus' => 'nullable|array',
            'menus.*' => 'integer|min:0'
        ]);

        // 3. Update Data Reservasi
        $reservation->update([
            'table_id' => $request->table_id,
            'reservation_date' => $request->reservation_date,
            'guest_count' => $request->guest_count,
            'notes' => $request->notes,
        ]);

        // 4. Update Pesanan Menu (Menggunakan sync)
        $syncData = [];
        if ($request->has('menus')) {
            foreach ($request->menus as $menuId => $quantity) {
                if ($quantity > 0) {
                    $syncData[$menuId] = ['quantity' => $quantity];
                }
            }
        }
        
        // Sync akan menghapus menu lama dan mengganti dengan yang baru
        $reservation->menus()->sync($syncData);

        return redirect()->route('reservations.index')
                         ->with('success', 'Perubahan reservasi berhasil disimpan.');
    }

    /**
     * (FR-08) Membatalkan reservasi.
     */
    public function destroy(Reservation $reservation)
    {
        if ($reservation->user_id !== Auth::id()) {
            abort(403);
        }

        // Soft delete logic: ubah status jadi cancelled
        $reservation->update(['status' => 'cancelled']);

        return redirect()->route('reservations.index')
                         ->with('success', 'Reservasi berhasil dibatalkan.');
    }
}
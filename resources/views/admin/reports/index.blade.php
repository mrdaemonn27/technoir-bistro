<x-app-layout>
    <style>
        .admin-reveal {
            opacity: 0;
            transform: translateY(14px);
            transition: opacity 520ms ease, transform 520ms ease;
        }

        .admin-reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .soft-card,
        .soft-row {
            transition: transform 200ms ease, background-color 200ms ease, box-shadow 200ms ease, border-color 200ms ease;
        }

        .soft-card:hover {
            transform: translateY(-3px);
            border-color: rgba(234, 142, 22, .36);
            box-shadow: 0 16px 38px rgba(117, 74, 25, .08);
        }

        .soft-row:hover {
            background-color: #fffaf2;
        }
    </style>

    <div class="min-h-screen bg-[#fbf7f1] text-[#1f1712]">
        <main class="mx-auto max-w-7xl px-6 py-10 lg:px-8">
            <section class="admin-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                <p class="text-xs font-black uppercase tracking-[0.2em] text-[#b76b0c]">Admin Laporan</p>
                <h1 class="mt-2 text-3xl font-black tracking-tight md:text-4xl">Laporan Keuangan</h1>
                <p class="mt-3 max-w-2xl text-sm leading-7 text-[#6b5b4c]">
                    Ringkasan pendapatan dan riwayat transaksi terbaru restoran.
                </p>
            </section>

            <section class="mt-6 grid grid-cols-1 gap-4 md:grid-cols-3">
                @foreach([
                    ['label' => 'Pendapatan Hari Ini', 'value' => $dailyRevenue, 'meta' => 'Transaksi hari berjalan'],
                    ['label' => 'Pendapatan Bulan Ini', 'value' => $monthlyRevenue, 'meta' => 'Akumulasi bulan aktif'],
                    ['label' => 'Total Pendapatan', 'value' => $totalRevenue, 'meta' => 'Seluruh transaksi tercatat'],
                ] as $item)
                    <article class="admin-reveal soft-card rounded-3xl border border-[#f0dfca] bg-white p-6">
                        <div class="flex items-start justify-between gap-4">
                            <div>
                                <p class="text-xs font-black uppercase tracking-[0.16em] text-[#a89583]">{{ $item['label'] }}</p>
                                <p class="mt-4 text-3xl font-black tracking-tight text-[#1f1712]">
                                    Rp {{ number_format($item['value'], 0, ',', '.') }}
                                </p>
                                <p class="mt-2 text-sm text-[#6b5b4c]">{{ $item['meta'] }}</p>
                            </div>
                            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#fff3df] text-[#c8740f]">
                                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-2.21 0-4 1.343-4 3s1.79 3 4 3 4-1.343 4-3-1.79-3-4-3z M3 11c2.4-4 5.4-6 9-6s6.6 2 9 6c-2.4 4-5.4 6-9 6s-6.6-2-9-6z" />
                                </svg>
                            </div>
                        </div>
                    </article>
                @endforeach
            </section>

            <section class="admin-reveal mt-6 overflow-hidden rounded-[28px] border border-[#f0dfca] bg-white shadow-sm">
                <div class="border-b border-[#f3e5d3] px-6 py-5">
                    <h2 class="text-lg font-black">Riwayat Transaksi Terbaru</h2>
                    <p class="mt-1 text-sm text-[#6b5b4c]">Data pembayaran terbaru yang tercatat di sistem.</p>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-[#fff8ed] text-xs font-black uppercase tracking-[0.14em] text-[#9b8067]">
                            <tr>
                                <th class="px-6 py-4">ID Transaksi</th>
                                <th class="px-6 py-4">Tanggal</th>
                                <th class="px-6 py-4">Pelanggan</th>
                                <th class="px-6 py-4">Metode</th>
                                <th class="px-6 py-4 text-right">Jumlah</th>
                                <th class="px-6 py-4 text-center">Status</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-[#f3e5d3]">
                            @forelse ($recentPayments as $payment)
                                <tr class="soft-row">
                                    <td class="px-6 py-5 font-black text-[#1f1712]">#{{ $payment->id }}</td>
                                    <td class="px-6 py-5 text-[#6b5b4c]">
                                        {{ \Carbon\Carbon::parse($payment->created_at)->format('d M Y H:i') }}
                                    </td>
                                    <td class="px-6 py-5">
                                        <p class="font-semibold text-[#1f1712]">
                                            {{ $payment->reservation->user->username ?? $payment->reservation->user->name ?? 'Guest' }}
                                        </p>
                                    </td>
                                    <td class="px-6 py-5">
                                        <span class="rounded-full bg-[#fff3df] px-3 py-1 text-xs font-black uppercase tracking-[0.1em] text-[#b76b0c]">
                                            {{ ucfirst($payment->payment_method ?? 'Cash') }}
                                        </span>
                                    </td>
                                    <td class="px-6 py-5 text-right font-black text-[#1f1712]">
                                        Rp {{ number_format($payment->amount, 0, ',', '.') }}
                                    </td>
                                    <td class="px-6 py-5 text-center">
                                        <span class="rounded-full bg-green-50 px-3 py-1 text-xs font-black uppercase tracking-[0.1em] text-green-700">
                                            Success
                                        </span>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="px-6 py-12 text-center text-sm text-[#6b5b4c]">
                                        Belum ada data transaksi.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="border-t border-[#f3e5d3] px-6 py-5">
                    {{ $recentPayments->links() }}
                </div>
            </section>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.admin-reveal').forEach((item, index) => {
                item.style.transitionDelay = `${Math.min(index * 55, 280)}ms`;
                requestAnimationFrame(() => item.classList.add('is-visible'));
            });
        });
    </script>
</x-app-layout>
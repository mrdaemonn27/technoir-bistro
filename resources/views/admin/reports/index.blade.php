<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Laporan Keuangan') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <!-- Statistik Cards -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <!-- Card Harian -->
                <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-blue-500">
                    <div class="text-gray-500 dark:text-gray-400 text-sm uppercase font-bold tracking-wider">Pendapatan Hari Ini</div>
                    <div class="text-3xl font-bold text-gray-900 dark:text-gray-100 mt-2">
                        Rp {{ number_format($dailyRevenue, 0, ',', '.') }}
                    </div>
                </div>

                <!-- Card Bulanan -->
                <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-green-500">
                    <div class="text-gray-500 dark:text-gray-400 text-sm uppercase font-bold tracking-wider">Pendapatan Bulan Ini</div>
                    <div class="text-3xl font-bold text-gray-900 dark:text-gray-100 mt-2">
                        Rp {{ number_format($monthlyRevenue, 0, ',', '.') }}
                    </div>
                </div>

                <!-- Card Total -->
                <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg p-6 border-l-4 border-purple-500">
                    <div class="text-gray-500 dark:text-gray-400 text-sm uppercase font-bold tracking-wider">Total Pendapatan</div>
                    <div class="text-3xl font-bold text-gray-900 dark:text-gray-100 mt-2">
                        Rp {{ number_format($totalRevenue, 0, ',', '.') }}
                    </div>
                </div>
            </div>

            <!-- Tabel Riwayat Transaksi -->
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">
                    <h3 class="text-lg font-bold mb-4">Riwayat Transaksi Terbaru</h3>

                    <div class="overflow-x-auto relative shadow-md sm:rounded-lg">
                        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
                            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
                                <tr>
                                    <th scope="col" class="py-3 px-6">ID Transaksi</th>
                                    <th scope="col" class="py-3 px-6">Tanggal</th>
                                    <th scope="col" class="py-3 px-6">Pelanggan</th>
                                    <th scope="col" class="py-3 px-6">Metode</th>
                                    <th scope="col" class="py-3 px-6 text-right">Jumlah (Rp)</th>
                                    <th scope="col" class="py-3 px-6 text-center">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse ($recentPayments as $payment)
                                    <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
                                        <td class="py-4 px-6 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                                            #{{ $payment->id }}
                                        </td>
                                        <td class="py-4 px-6">
                                            {{ \Carbon\Carbon::parse($payment->created_at)->format('d M Y H:i') }}
                                        </td>
                                        <td class="py-4 px-6">
                                            {{ $payment->reservation->user->name ?? 'Guest' }}
                                        </td>
                                        <td class="py-4 px-6">
                                            <span class="bg-gray-100 text-gray-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-gray-300">
                                                {{ ucfirst($payment->payment_method ?? 'Cash') }}
                                            </span>
                                        </td>
                                        <td class="py-4 px-6 text-right font-bold text-gray-900 dark:text-white">
                                            Rp {{ number_format($payment->amount, 0, ',', '.') }}
                                        </td>
                                        <td class="py-4 px-6 text-center">
                                            <span class="bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300">
                                                Success
                                            </span>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="6" class="py-4 px-6 text-center text-gray-500 dark:text-gray-400">
                                            Belum ada data transaksi.
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="mt-4">
                        {{ $recentPayments->links() }}
                    </div>

                </div>
            </div>
        </div>
    </div>
</x-app-layout>
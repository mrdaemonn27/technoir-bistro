<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Admin Dashboard') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">
                    <h3 class="text-lg font-bold mb-4">Selamat Datang, Admin!</h3>
                    <p class="mb-6">Ini adalah pusat kontrol restoran Anda.</p>
                    
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <!-- Link Cepat ke Manajemen Menu -->
                        <a href="{{ route('admin.menus.index') }}" class="block p-6 bg-indigo-50 dark:bg-indigo-900/20 border border-indigo-100 dark:border-indigo-800 rounded-lg hover:shadow-md transition group">
                            <div class="text-indigo-500 mb-2 group-hover:scale-110 transition-transform">
                                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path></svg>
                            </div>
                            <h3 class="text-lg font-bold text-indigo-700 dark:text-indigo-300">Kelola Menu</h3>
                            <p class="text-sm text-gray-600 dark:text-gray-400 mt-2">Tambah, edit, atau hapus makanan & minuman.</p>
                        </a>
                        
                        <!-- Placeholder Statistik -->
                        <div class="block p-6 bg-gray-50 dark:bg-gray-700/20 border border-gray-100 dark:border-gray-700 rounded-lg">
                            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-300">Reservasi Masuk</h3>
                            <p class="text-sm text-gray-500 dark:text-gray-400 mt-2">Cek pesanan meja yang akan datang.</p>
                        </div>

                         <div class="block p-6 bg-gray-50 dark:bg-gray-700/20 border border-gray-100 dark:border-gray-700 rounded-lg">
                            <h3 class="text-lg font-bold text-gray-700 dark:text-gray-300">Laporan Keuangan</h3>
                            <p class="text-sm text-gray-500 dark:text-gray-400 mt-2">Lihat total pendapatan harian/bulanan.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
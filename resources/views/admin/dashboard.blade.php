<x-app-layout>
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <div class="text-center mb-10">
                <span class="text-[#E5A024] font-serif italic text-xl">Main Control</span>
                <h2 class="text-3xl font-bold text-[#2D2D2D]">Dashboard Administrator</h2>
            </div>

            <div class="bg-white rounded-xl shadow-md overflow-hidden border-l-4 border-indigo-500 mb-8">
                <div class="p-8">
                    <h3 class="text-2xl font-bold text-[#2D2D2D] mb-2">Selamat Datang, {{ Auth::user()->username }}!</h3>
                    <p class="text-gray-600">Ini adalah pusat kontrol restoran Anda. Kelola menu, reservasi, dan pantau performa bisnis dari sini.</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                
                <!-- 1. Kelola Menu -->
                <a href="{{ route('admin.menus.index') }}" class="group bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-all border border-transparent hover:border-indigo-500">
                    <div class="text-indigo-500 mb-4 group-hover:scale-110 transition-transform">
                        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-[#2D2D2D] mb-2">Kelola Menu</h3>
                    <p class="text-sm text-gray-500">Tambah, edit, atau hapus item makanan dan minuman di restoran.</p>
                </a>
                
                <!-- 2. Reservasi Masuk -->
                <a href="{{ route('admin.reservations.index') }}" class="group bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-all border border-transparent hover:border-green-500">
                    <div class="text-green-500 mb-4 group-hover:scale-110 transition-transform">
                        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-[#2D2D2D] mb-2">Reservasi Masuk</h3>
                    <p class="text-sm text-gray-500">Pantau dan kelola pesanan meja dari pelanggan secara realtime.</p>
                </a>

                <!-- 3. Laporan Keuangan -->
                <a href="{{ route('admin.reports.index') }}" class="group bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-all border border-transparent hover:border-yellow-500">
                    <div class="text-yellow-500 mb-4 group-hover:scale-110 transition-transform">
                        <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-[#2D2D2D] mb-2">Laporan Keuangan</h3>
                    <p class="text-sm text-gray-500">Analisis pendapatan harian dan bulanan bisnis Anda.</p>
                </a>

            </div>
        </div>
    </div>
</x-app-layout>
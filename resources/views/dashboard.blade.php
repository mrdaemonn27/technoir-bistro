<x-app-layout>
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <div class="text-center mb-10">
                <span class="text-[#E5A024] font-serif italic text-xl">Welcome Back</span>
                <h2 class="text-3xl font-bold text-[#2D2D2D]">Dashboard Pelanggan</h2>
            </div>

            <div class="bg-white rounded-xl shadow-md overflow-hidden border-l-4 border-[#E5A024] mb-8">
                <div class="p-8 text-center">
                    <h3 class="text-2xl font-bold text-[#2D2D2D] mb-2">Halo, {{ Auth::user()->username }}!</h3>
                    <p class="text-gray-600">Senang melihat Anda kembali di Technoir Bistro. Apa yang ingin Anda lakukan hari ini?</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <!-- Profile -->
                <a href="{{ route('profile.edit') }}" class="group bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-all border border-transparent hover:border-[#E5A024]">
                    <div class="text-[#E5A024] mb-4 group-hover:scale-110 transition-transform">
                        <svg class="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                    </div>
                    <h4 class="text-xl font-bold text-[#2D2D2D] mb-2 text-center">Profil Saya</h4>
                    <p class="text-sm text-gray-500 text-center">Kelola informasi akun dan pengaturan keamanan Anda.</p>
                </a>
                
                <!-- Reservations -->
                <a href="{{ route('reservations.index') }}" class="group bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-all border border-transparent hover:border-[#E5A024]">
                    <div class="text-[#E5A024] mb-4 group-hover:scale-110 transition-transform">
                        <svg class="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <h4 class="text-xl font-bold text-[#2D2D2D] mb-2 text-center">Reservasi</h4>
                    <p class="text-sm text-gray-500 text-center">Lihat riwayat dan status pemesanan meja Anda.</p>
                </a>
                
                <!-- Tables -->
                <a href="{{ route('tables.index') }}" class="group bg-white p-8 rounded-xl shadow-sm hover:shadow-md transition-all border border-transparent hover:border-[#E5A024]">
                    <div class="text-[#E5A024] mb-4 group-hover:scale-110 transition-transform">
                        <svg class="w-12 h-12 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                        </svg>
                    </div>
                    <h4 class="text-xl font-bold text-[#2D2D2D] mb-2 text-center">Cek Meja</h4>
                    <p class="text-sm text-gray-500 text-center">Lihat ketersediaan meja untuk kunjungan Anda berikutnya.</p>
                </a>
            </div>

            <div class="mt-12 text-center">
                <a href="{{ route('menu.index') }}" class="inline-block bg-[#E5A024] hover:bg-[#2D2D2D] text-white font-bold py-4 px-10 rounded-full transition-all shadow-lg transform hover:-translate-y-1">
                    Lihat Menu Kami
                </a>
            </div>
        </div>
    </div>
</x-app-layout>
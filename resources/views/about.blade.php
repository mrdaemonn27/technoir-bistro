<x-app-layout>
    {{-- TEMA: Cream (#FFF8F5), Dark (#2D2D2D), Gold (#E5A024) --}}

    {{-- 1. HERO BANNER --}}
    <div class="relative bg-[#2D2D2D] py-24 text-center overflow-hidden">
        {{-- Background Image Overlay --}}
        <div class="absolute inset-0 opacity-30">
            <img src="https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1920&q=80" class="w-full h-full object-cover">
        </div>
        <div class="relative z-10 max-w-4xl mx-auto px-4">
            <span class="text-[#E5A024] font-serif italic text-xl tracking-widest">Our Story</span>
            <h1 class="text-4xl md:text-6xl font-bold text-white mt-4 mb-6">Tentang Technoir Bistro</h1>
            <p class="text-gray-300 text-lg max-w-2xl mx-auto">
                Mengenal lebih dekat perjalanan kami dalam menyajikan cita rasa masa depan dengan sentuhan tradisi.
            </p>
        </div>
    </div>

    {{-- 2. STORY SECTION --}}
    <div class="py-20 bg-[#FFF8F5]">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col md:flex-row items-center gap-16">
                <div class="md:w-1/2">
                    <div class="relative p-4 border-2 border-[#E5A024] rounded-tr-[100px] rounded-bl-[100px]">
                        <img src="https://images.unsplash.com/photo-1600565193348-f74bd3c7ccdf?auto=format&fit=crop&w=800&q=80" alt="Chef Cooking" class="w-full h-auto rounded-tr-[80px] rounded-bl-[80px] shadow-xl">
                    </div>
                </div>
                <div class="md:w-1/2">
                    <h2 class="text-3xl font-bold text-[#2D2D2D] mb-6">Awal Mula Perjalanan</h2>
                    <p class="text-gray-600 mb-4 leading-relaxed">
                        Technoir Bistro didirikan pada tahun 2025 dengan visi sederhana: menciptakan tempat di mana teknologi dan kuliner dapat berpadu secara harmonis. Kami percaya bahwa makanan bukan hanya sekadar kebutuhan, tetapi sebuah seni yang terus berkembang.
                    </p>
                    <p class="text-gray-600 mb-6 leading-relaxed">
                        Berlokasi di jantung kota Bandung, kami mengusung konsep Cyber-Gastronomy, di mana setiap hidangan disiapkan dengan presisi tinggi namun tetap mempertahankan kehangatan rasa rumahan.
                    </p>
                    
                    <div class="grid grid-cols-2 gap-6 mt-8">
                        <div class="text-center p-6 bg-white rounded-lg shadow-sm border-b-4 border-[#E5A024]">
                            <h4 class="text-4xl font-bold text-[#2D2D2D]">15+</h4>
                            <p class="text-sm text-gray-500 mt-2">Tahun Pengalaman</p>
                        </div>
                        <div class="text-center p-6 bg-white rounded-lg shadow-sm border-b-4 border-[#E5A024]">
                            <h4 class="text-4xl font-bold text-[#2D2D2D]">20k+</h4>
                            <p class="text-sm text-gray-500 mt-2">Pelanggan Bahagia</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 3. VISION & MISSION --}}
    <div class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 class="text-3xl font-bold text-[#2D2D2D] mb-12">Visi & Misi Kami</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                {{-- Card 1 --}}
                <div class="p-8 bg-[#FFF8F5] rounded-xl hover:shadow-lg transition duration-300 group">
                    <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-6 text-[#E5A024] shadow-sm group-hover:bg-[#E5A024] group-hover:text-white transition">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-[#2D2D2D] mb-3">Inovasi Rasa</h3>
                    <p class="text-gray-600 text-sm">Selalu menciptakan menu baru yang unik dengan memadukan bahan lokal dan teknik modern.</p>
                </div>

                {{-- Card 2 --}}
                <div class="p-8 bg-[#FFF8F5] rounded-xl hover:shadow-lg transition duration-300 group">
                    <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-6 text-[#E5A024] shadow-sm group-hover:bg-[#E5A024] group-hover:text-white transition">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-[#2D2D2D] mb-3">Pelayanan Sepenuh Hati</h3>
                    <p class="text-gray-600 text-sm">Memberikan pengalaman bersantap yang ramah, hangat, dan tak terlupakan bagi setiap tamu.</p>
                </div>

                {{-- Card 3 --}}
                <div class="p-8 bg-[#FFF8F5] rounded-xl hover:shadow-lg transition duration-300 group">
                    <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-6 text-[#E5A024] shadow-sm group-hover:bg-[#E5A024] group-hover:text-white transition">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <h3 class="text-xl font-bold text-[#2D2D2D] mb-3">Keberlanjutan</h3>
                    <p class="text-gray-600 text-sm">Menggunakan bahan-bahan organik dan ramah lingkungan untuk mendukung bumi yang lebih hijau.</p>
                </div>
            </div>
        </div>
    </div>

    {{-- 4. TEAM SECTION --}}
    <div class="py-20 bg-[#2D2D2D] text-white text-center">
        <div class="max-w-7xl mx-auto px-4">
            <span class="text-[#E5A024] font-serif italic text-lg mb-2 block">Our Experts</span>
            <h2 class="text-3xl font-bold mb-12">Meet The Chefs</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <div class="group">
                    <div class="relative overflow-hidden rounded-lg mb-4">
                        <img src="https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&w=400&q=80" alt="Chef 1" class="w-full h-80 object-cover grayscale group-hover:grayscale-0 transition duration-500 transform group-hover:scale-105">
                    </div>
                    <h4 class="text-xl font-bold">Chef Junaedi</h4>
                    <p class="text-[#E5A024] text-sm">Executive Chef</p>
                </div>
                <div class="group">
                    <div class="relative overflow-hidden rounded-lg mb-4">
                        <img src="https://plus.unsplash.com/premium_photo-1664478052858-d137d26e2cfd?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Chef 2" class="w-full h-80 object-cover grayscale group-hover:grayscale-0 transition duration-500 transform group-hover:scale-105">
                    </div>
                    <h4 class="text-xl font-bold">Chef Sarah</h4>
                    <p class="text-[#E5A024] text-sm">Pastry Specialist</p>
                </div>
                <div class="group">
                    <div class="relative overflow-hidden rounded-lg mb-4">
                        <img src="https://images.unsplash.com/photo-1723083466985-d462dc26a9a3?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="Chef 3" class="w-full h-80 object-cover grayscale group-hover:grayscale-0 transition duration-500 transform group-hover:scale-105">
                    </div>
                    <h4 class="text-xl font-bold">Chef Reza</h4>
                    <p class="text-[#E5A024] text-sm">Sous Chef</p>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
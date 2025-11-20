<x-app-layout>
    {{-- 
        RESTONEST THEME:
        - Background Utama: Cream (#FFF8F5)
        - Text Utama: Dark Grey (#2D2D2D)
        - Aksen: Gold/Orange (#E5A024)
        - Button: Black or Gold
    --}}

    {{-- 1. HERO SECTION --}}
    <div class="bg-[#FFF8F5] relative overflow-hidden pt-16 pb-20 lg:pt-24 lg:pb-32">
        {{-- Dekorasi Latar Belakang (Abstrak Garis) --}}
        <div class="absolute top-0 right-0 -mr-20 -mt-20 w-96 h-96 rounded-full border-2 border-[#E5A024]/20 z-0"></div>
        <div class="absolute bottom-0 left-0 -ml-20 -mb-20 w-72 h-72 rounded-full border-2 border-[#E5A024]/20 z-0"></div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
                
                {{-- Teks Kiri --}}
                <div class="text-center lg:text-left">
                    <span class="text-[#E5A024] font-serif italic text-xl mb-2 block">Welcome to</span>
                    <h1 class="text-5xl md:text-7xl font-extrabold text-[#2D2D2D] leading-tight mb-6">
                        Technoir <br> <span class="text-[#E5A024]">Bistro</span>
                    </h1>
                    <p class="text-gray-600 text-lg mb-8 max-w-lg mx-auto lg:mx-0 leading-relaxed">
                        Nikmati perpaduan cita rasa otentik dengan suasana yang hangat dan nyaman. Tempat terbaik untuk momen spesial Anda.
                    </p>
                    <div class="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                        <a href="{{ route('menu.index') }}" class="inline-block bg-[#1A1A1A] text-white font-bold py-4 px-10 rounded-full hover:bg-[#E5A024] transition duration-300 shadow-lg">
                            View Menu
                        </a>
                        <a href="{{ route('reservations.create') }}" class="inline-block border-2 border-[#1A1A1A] text-[#1A1A1A] font-bold py-4 px-10 rounded-full hover:bg-[#1A1A1A] hover:text-white transition duration-300">
                            Book a Table
                        </a>
                    </div>
                </div>

                {{-- Gambar Kanan (Arch Shape - RestoNest Style) --}}
                <div class="relative flex justify-center">
                    <div class="relative w-80 h-96 md:w-[450px] md:h-[550px] rounded-t-[150px] overflow-hidden border-8 border-white shadow-2xl z-10">
                        {{-- Gambar Hero Statis yang Elegan --}}
                        <img src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80" alt="Hero Image" class="w-full h-full object-cover hover:scale-105 transition duration-700">
                    </div>
                    
                    {{-- Dekorasi Lingkaran --}}
                    <div class="absolute -bottom-10 -right-10 w-40 h-40 border-4 border-[#E5A024] rounded-full z-0 hidden md:block"></div>
                    <div class="absolute top-20 -left-10 w-20 h-20 bg-[#E5A024] rounded-full opacity-20 z-0 hidden md:block"></div>
                </div>
            </div>

            {{-- 3 Fitur Bulat (Icon Orange) --}}
            <div class="mt-24 grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
                <div class="flex flex-col items-center group">
                    <div class="w-20 h-20 bg-white rounded-full flex items-center justify-center text-[#E5A024] shadow-md mb-4 group-hover:bg-[#E5A024] group-hover:text-white transition duration-300">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    </div>
                    <h4 class="font-bold text-[#2D2D2D] text-lg">Buka Setiap Hari</h4>
                    <p class="text-gray-500 text-sm mt-2">10:00 AM - 10:00 PM</p>
                </div>
                <div class="flex flex-col items-center group">
                    <div class="w-20 h-20 bg-white rounded-full flex items-center justify-center text-[#E5A024] shadow-md mb-4 group-hover:bg-[#E5A024] group-hover:text-white transition duration-300">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>
                    </div>
                    <h4 class="font-bold text-[#2D2D2D] text-lg">Reservasi Mudah</h4>
                    <p class="text-gray-500 text-sm mt-2">Booking meja via website</p>
                </div>
                <div class="flex flex-col items-center group">
                    <div class="w-20 h-20 bg-white rounded-full flex items-center justify-center text-[#E5A024] shadow-md mb-4 group-hover:bg-[#E5A024] group-hover:text-white transition duration-300">
                        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                    </div>
                    <h4 class="font-bold text-[#2D2D2D] text-lg">Lokasi Nyaman</h4>
                    <p class="text-gray-500 text-sm mt-2">Jantung Kota Bandung</p>
                </div>
            </div>
        </div>
    </div>

    {{-- 2. THE STORY SECTION (White Background) --}}
    <div class="py-24 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col lg:flex-row items-center gap-16">
                {{-- Gambar Kiri --}}
                <div class="lg:w-1/2">
                    <div class="relative">
                        <img src="https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=80" alt="Story" class="rounded-lg shadow-xl w-full object-cover h-[400px]">
                        <div class="absolute -bottom-6 -right-6 bg-[#E5A024] text-white p-6 rounded-lg shadow-lg">
                            <p class="font-serif italic text-lg">Since</p>
                            <p class="text-3xl font-bold">1998</p>
                        </div>
                    </div>
                </div>
                {{-- Teks Kanan --}}
                <div class="lg:w-1/2">
                    <span class="text-[#E5A024] font-bold tracking-widest text-sm uppercase mb-2 block">Tentang Kami</span>
                    <h2 class="text-4xl font-bold text-[#2D2D2D] mb-6 font-serif">The Story</h2>
                    <p class="text-gray-600 mb-6 leading-relaxed">
                        Berawal dari resep keluarga yang sederhana, Technoir Bistro tumbuh menjadi tempat di mana tradisi bertemu dengan inovasi. Kami percaya bahwa makanan bukan hanya soal rasa, tapi juga tentang cerita dan kehangatan.
                    </p>
                    <div class="grid grid-cols-2 gap-8 mt-8 border-t border-gray-200 pt-8">
                        <div>
                            <h4 class="text-4xl font-bold text-[#2D2D2D]">25+</h4>
                            <p class="text-sm text-gray-500">Tahun Pengalaman</p>
                        </div>
                        <div>
                            <h4 class="text-4xl font-bold text-[#2D2D2D]">150+</h4>
                            <p class="text-sm text-gray-500">Menu Spesial</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 3. POPULAR DISHES (Cream Background, White Cards) --}}
    <div class="py-24 bg-[#FFF8F5]">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <span class="text-[#E5A024] font-serif italic text-xl">Menu Favorit</span>
            <h2 class="text-4xl font-bold text-[#2D2D2D] mb-12 font-serif">Popular Dishes</h2>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                @forelse($featuredMenus as $menu)
                <div class="bg-white rounded-xl shadow-lg overflow-hidden hover:-translate-y-2 transition duration-300 group">
                    <div class="h-64 overflow-hidden relative">
                        {{-- LOGIKA GAMBAR DINAMIS (SAMA SEPERTI SEBELUMNYA, TAPI TANPA NEON) --}}
                        <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                             alt="{{ $menu->name }}" 
                             class="w-full h-full object-cover group-hover:scale-110 transition duration-500"
                             onerror="this.onerror=null; this.src='https://placehold.co/400x300/E5E5E5/555?text=No+Image';">
                        
                        <div class="absolute top-4 right-4 bg-white text-[#2D2D2D] px-3 py-1 rounded-full text-xs font-bold shadow-md">
                            {{ $menu->category->name }}
                        </div>
                    </div>
                    
                    <div class="p-6 text-left">
                        <div class="flex justify-between items-center mb-2">
                            <h3 class="text-xl font-bold text-[#2D2D2D] group-hover:text-[#E5A024] transition">{{ $menu->name }}</h3>
                            <span class="text-[#E5A024] font-bold text-lg">Rp {{ number_format($menu->price/1000, 0) }}K</span>
                        </div>
                        <p class="text-gray-500 text-sm mb-6 line-clamp-2">{{ $menu->description }}</p>
                        
                        <div class="flex justify-between items-center border-t border-gray-100 pt-4">
                            <a href="{{ route('menu.index') }}" class="text-[#2D2D2D] font-semibold hover:text-[#E5A024] transition uppercase text-sm tracking-wide">Lihat Detail</a>
                            <button class="bg-[#E5A024] text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-[#2D2D2D] transition shadow-md">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                            </button>
                        </div>
                    </div>
                </div>
                @empty
                    <div class="col-span-3 py-12 text-center text-gray-500">
                        <p>Data menu belum tersedia.</p>
                    </div>
                @endforelse
            </div>
            
            <div class="mt-16">
                <a href="{{ route('menu.index') }}" class="inline-block bg-[#2D2D2D] text-white font-bold py-3 px-8 rounded-full hover:bg-[#E5A024] transition duration-300">
                    Lihat Semua Menu
                </a>
            </div>
        </div>
    </div>

    {{-- 4. OUR SERVICES (Dark Box Style like Image) --}}
    <div class="py-24 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col lg:flex-row gap-12 items-center">
                <div class="lg:w-1/3">
                    <span class="text-[#E5A024] font-bold tracking-widest text-sm uppercase mb-2 block">Layanan Kami</span>
                    <h2 class="text-4xl font-bold text-[#2D2D2D] mb-6 font-serif">Our Great Services</h2>
                    <p class="text-gray-600 mb-8 leading-relaxed">
                        Kami berkomitmen memberikan pelayanan terbaik untuk kenyamanan Anda. Dari reservasi online yang mudah hingga ruang makan privat yang eksklusif.
                    </p>
                </div>
                
                <div class="lg:w-2/3 grid grid-cols-1 md:grid-cols-3 gap-6">
                    {{-- Service Card 1 --}}
                    <div class="bg-[#2D2D2D] p-8 rounded-xl text-center text-white hover:bg-[#E5A024] transition duration-300 group shadow-xl">
                        <div class="w-16 h-16 bg-white/10 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-white group-hover:text-[#E5A024] transition-colors">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                        </div>
                        <h4 class="font-bold text-lg mb-2">Online Booking</h4>
                        <p class="text-sm text-gray-400 group-hover:text-white/90">Reservasi meja instan via website.</p>
                    </div>
                    
                    {{-- Service Card 2 --}}
                    <div class="bg-[#2D2D2D] p-8 rounded-xl text-center text-white hover:bg-[#E5A024] transition duration-300 group shadow-xl">
                        <div class="w-16 h-16 bg-white/10 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-white group-hover:text-[#E5A024] transition-colors">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path></svg>
                        </div>
                        <h4 class="font-bold text-lg mb-2">Private Dining</h4>
                        <p class="text-sm text-gray-400 group-hover:text-white/90">Ruang eksklusif untuk acara privat.</p>
                    </div>

                    {{-- Service Card 3 --}}
                    <div class="bg-[#2D2D2D] p-8 rounded-xl text-center text-white hover:bg-[#E5A024] transition duration-300 group shadow-xl">
                        <div class="w-16 h-16 bg-white/10 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-white group-hover:text-[#E5A024] transition-colors">
                            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
                        </div>
                        <h4 class="font-bold text-lg mb-2">Catering</h4>
                        <p class="text-sm text-gray-400 group-hover:text-white/90">Layanan katering untuk event spesial.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 5. RESERVATION CTA (Dark Overlay Background) --}}
    <div class="relative py-32 bg-fixed bg-cover bg-center" style="background-image: url('https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=1200&q=80');">
        <div class="absolute inset-0 bg-black/60"></div> 
        
        <div class="relative z-10 max-w-4xl mx-auto px-4 text-center text-white">
            <h2 class="text-4xl md:text-5xl font-bold mb-8 font-serif">Rock Your Table Now</h2>
            
            <div class="bg-white/10 backdrop-blur-md p-8 rounded-2xl border border-white/20">
                <form action="{{ route('reservations.store') }}" method="POST" class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
                    @csrf
                    <div class="text-left">
                        <label class="block text-xs text-gray-300 mb-2 uppercase tracking-widest">Jumlah Tamu</label>
                        <input type="number" name="guest_count" min="1" value="2" class="w-full bg-white text-gray-900 border-none rounded-md focus:ring-[#E5A024]" required>
                    </div>

                    <div class="text-left">
                        <label class="block text-xs text-gray-300 mb-2 uppercase tracking-widest">Waktu & Tanggal</label>
                        <input type="datetime-local" name="reservation_date" class="w-full bg-white text-gray-900 border-none rounded-md focus:ring-[#E5A024]" required>
                    </div>

                    {{-- Tombol Action: Arahkan ke halaman form reservasi untuk detail lebih lanjut --}}
                    <div class="md:col-span-2">
                         <a href="{{ route('reservations.create') }}" class="block w-full bg-[#E5A024] hover:bg-orange-600 text-white font-bold py-3 px-4 rounded-md transition text-center uppercase tracking-widest shadow-lg">
                            Book Now
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    {{-- 6. FOOTER (Black & Gold) --}}
    <footer class="bg-[#111111] text-white pt-20 pb-10 border-t border-gray-800">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col items-center text-center mb-12">
                <div class="mb-6">
                     <x-application-logo class="block h-16 w-auto fill-current text-[#E5A024]" />
                </div>
                <h3 class="text-3xl font-bold tracking-wide mb-4">TECHNOIR <span class="text-[#E5A024]">BISTRO</span></h3>
                <p class="text-gray-500 mt-2 max-w-md">
                    Jl. Braga No. 100, Bandung, Indonesia<br>
                    +62 812 3456 7890 | hello@technoir.com
                </p>
                
                <div class="flex gap-4 mt-6">
                    {{-- Facebook Icon --}}
                    <a href="#" class="w-10 h-10 rounded-full bg-gray-800 flex items-center justify-center hover:bg-[#E5A024] transition text-white group">
                        <svg class="w-5 h-5 group-hover:text-white" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                            <path fill-rule="evenodd" d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z" clip-rule="evenodd" />
                        </svg>
                    </a>
                    
                    {{-- Instagram Icon --}}
                    <a href="#" class="w-10 h-10 rounded-full bg-gray-800 flex items-center justify-center hover:bg-[#E5A024] transition text-white group">
                        <svg class="w-5 h-5 group-hover:text-white" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                            <path fill-rule="evenodd" d="M12.315 2c2.43 0 2.784.013 3.808.06 1.064.049 1.791.218 2.427.465a4.902 4.902 0 011.772 1.153 4.902 4.902 0 011.153 1.772c.247.636.416 1.363.465 2.427.048 1.067.06 1.407.06 4.123v.08c0 2.643-.012 2.987-.06 4.043-.049 1.064-.218 1.791-.465 2.427a4.902 4.902 0 01-1.153 1.772 4.902 4.902 0 01-1.772 1.153c-.636.247-1.363.416-2.427.465-1.067.048-1.407.06-4.123.06h-.08c-2.643 0-2.987-.012-4.043-.06-1.064-.049-1.791-.218-2.427-.465a4.902 4.902 0 01-1.772-1.153 4.902 4.902 0 01-1.153-1.772c-.247-.636-.416-1.363-.465-2.427-.047-1.024-.06-1.379-.06-3.808v-.63c0-2.43.013-2.784.06-3.808.049-1.064.218-1.791.465-2.427a4.902 4.902 0 011.153-1.772A4.902 4.902 0 015.468 2.527c.636-.247 1.363-.416 2.427-.465C8.901 2.013 9.256 2 11.685 2h.63zm-.081 1.802h-.468c-2.456 0-2.784.011-3.807.058-.975.045-1.504.207-1.857.344-.467.182-.8.398-1.15.748-.35.35-.566.683-.748 1.15-.137.353-.3.882-.344 1.857-.047 1.023-.058 1.351-.058 3.807v.468c0 2.456.011 2.784.058 3.807.045.975.207 1.504.344 1.857.182.466.399.8.748 1.15.35.35.683.566 1.15.748.353.137.882.3 1.857.344 1.054.048 1.37.058 4.041.058h.08c2.597 0 2.917-.01 3.96-.058.976-.045 1.505-.207 1.858-.344.466-.182.8-.398 1.15-.748.35-.35.566-.683.748-1.15.137-.353.3-.882.344-1.857.048-1.055.058-1.37.058-4.041v-.08c0-2.597-.01-2.917-.058-3.96-.045-.976-.207-1.505-.344-1.858a3.097 3.097 0 00-.748-1.15 3.098 3.098 0 00-1.15-.748c-.353-.137-.882-.3-1.857-.344-1.023-.047-1.351-.058-3.807-.058zM12 6.865a5.135 5.135 0 110 10.27 5.135 5.135 0 010-10.27zm0 1.802a3.333 3.333 0 100 6.666 3.333 3.333 0 000-6.666zm5.338-3.205a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4z" clip-rule="evenodd" />
                        </svg>
                    </a>

                    {{-- Twitter/X Icon --}}
                    <a href="#" class="w-10 h-10 rounded-full bg-gray-800 flex items-center justify-center hover:bg-[#E5A024] transition text-white group">
                        <svg class="w-5 h-5 group-hover:text-white" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" />
                        </svg>
                    </a>
                </div>
            </div>

            <div class="border-t border-gray-800 pt-8 flex flex-col md:flex-row justify-between items-center text-xs text-gray-600 uppercase tracking-widest">
                <p>&copy; 2025 Technoir Bistro. All Rights Reserved.</p>
                <div class="flex gap-6 mt-4 md:mt-0">
                    <a href="#" class="hover:text-[#E5A024] transition">Privacy Policy</a>
                    <a href="#" class="hover:text-[#E5A024] transition">Terms of Use</a>
                </div>
            </div>
        </div>
    </footer>
</x-app-layout>
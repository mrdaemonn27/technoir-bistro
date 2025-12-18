<x-app-layout>
    {{-- TEMA: Background Cream (#FFF8F5) --}}
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            {{-- Flash Message --}}
            @if (session('success'))
                <div class="mb-6 max-w-xl mx-auto">
                    <div class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm shadow-sm">
                        {{ session('success') }}
                    </div>
                </div>
            @endif
            
            {{-- Header Title --}}
            <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-12">
                <div class="text-center md:text-left">
                    <span class="text-[#E5A024] font-serif italic text-xl">Our Selection</span>
                    <h2 class="text-4xl font-bold text-[#2D2D2D] mt-2">Daftar Menu Technoir</h2>
                    <p class="text-gray-600 mt-4 max-w-2xl">
                        Nikmati sajian masa depan dengan pilihan menu terbaik yang memadukan cita rasa klasik dan sentuhan cybernetic.
                    </p>
                </div>

                @auth
                    @if(!Auth::user()->is_admin)
                        <div class="mt-6 md:mt-0">
                            <a href="{{ route('favorites.index') }}" class="inline-flex items-center px-4 py-2 bg-[#2D2D2D] hover:bg-[#E5A024] text-white text-sm font-semibold rounded-full shadow transition">
                                Lihat Menu Favorit
                            </a>
                        </div>
                    @endif
                @endauth
            </div>

            {{-- Grid Layout --}}
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                
                @forelse ($menus as $menu)
                    <div class="group bg-white rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 overflow-hidden border-t-4 border-[#E5A024]">
                        
                        {{-- 1. Gambar Menu --}}
                        <div class="h-56 w-full bg-gray-200 relative overflow-hidden">
                            @if($menu->image)
                                <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                     alt="{{ $menu->name }}" 
                                     class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700"
                                     onerror="this.onerror=null; this.src='https://placehold.co/600x400/1a202c/FFF?text={{ urlencode($menu->name) }}';">
                            @else
                                <img src="https://placehold.co/600x400/1a202c/FFF?text={{ urlencode($menu->name) }}" 
                                     alt="{{ $menu->name }}" 
                                     class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700">
                            @endif

                            {{-- Badge Kategori --}}
                            @if($menu->category)
                                <div class="absolute top-4 right-4 bg-[#2D2D2D] text-[#E5A024] text-xs font-bold px-3 py-1.5 rounded-full shadow-md tracking-wider uppercase">
                                    {{ $menu->category->name }}
                                </div>
                            @endif
                        </div>

                        {{-- 2. Informasi Menu --}}
                        <div class="p-6">
                            <div class="flex justify-between items-start mb-3">
                                <h4 class="font-bold text-xl text-[#2D2D2D] group-hover:text-[#E5A024] transition-colors duration-300 line-clamp-1" title="{{ $menu->name }}">
                                    {{ $menu->name }}
                                </h4>

                                @auth
                                    @if(!Auth::user()->is_admin)
                                        <form action="{{ route('favorites.store') }}" method="POST">
                                            @csrf
                                            <input type="hidden" name="menu_id" value="{{ $menu->id }}">
                                            <button type="submit" class="text-gray-300 hover:text-red-500 transition" title="Tambah / Hapus dari Favorit">
                                                &#9829;
                                            </button>
                                        </form>
                                    @endif
                                @endauth
                            </div>
                            
                            <p class="text-sm text-gray-600 mb-6 line-clamp-3 min-h-[60px] leading-relaxed">
                                {{ $menu->description }}
                            </p>

                            <div class="flex justify-between items-center pt-4 border-t border-gray-100">
                                <div class="flex flex-col">
                                    <span class="text-xs text-gray-400 uppercase tracking-wider font-semibold">Harga</span>
                                    <span class="text-2xl font-bold text-[#E5A024]">
                                        Rp {{ number_format($menu->price, 0, ',', '.') }}
                                    </span>
                                </div>
                                
                                {{-- Status Badge --}}
                                <span class="px-3 py-1 rounded-full text-xs font-bold {{ $menu->availability ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' }}">
                                    {{ $menu->availability ? 'Tersedia' : 'Habis' }}
                                </span>
                            </div>
                        </div>
                    </div>
                @empty
                    <div class="col-span-full text-center py-16">
                        <div class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-[#FFF8F5] mb-6">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-[#E5A024]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                            </svg>
                        </div>
                        <h3 class="text-xl font-bold text-[#2D2D2D] mb-2">Belum ada menu</h3>
                        <p class="text-gray-500">Menu sedang disiapkan oleh chef kami. Silakan kembali lagi nanti.</p>
                    </div>
                @endforelse

            </div>
        </div>
    </div>
</x-app-layout>
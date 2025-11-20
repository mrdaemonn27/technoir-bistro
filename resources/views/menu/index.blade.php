<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Daftar Menu Technoir') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            {{-- Header Banner Sederhana --}}
            <div class="mb-8 text-center">
                <h3 class="text-3xl font-bold text-gray-800 dark:text-white">Nikmati Sajian Masa Depan</h3>
                <p class="text-gray-600 dark:text-gray-400 mt-2">Pilihan menu terbaik dengan cita rasa cybernetic.</p>
            </div>

            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg p-6">
                
                {{-- Grid Layout yang Lebih Rapi --}}
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    @forelse ($menus as $menu)
                        <div class="group bg-white dark:bg-gray-700 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1 overflow-hidden border border-gray-100 dark:border-gray-600">
                            
                            {{-- 1. Gambar Menu (Placeholder Otomatis) --}}
                            <div class="h-48 w-full bg-gray-200 relative overflow-hidden">
                                {{-- Kita pakai layanan Placehold.co untuk gambar dummy yang cantik --}}
                                <img src="https://placehold.co/600x400/1a202c/FFF?text={{ urlencode($menu->name) }}" 
                                     alt="{{ $menu->name }}" 
                                     class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500">
                                
                                {{-- Badge Kategori --}}
                                <div class="absolute top-3 right-3 bg-indigo-600 text-white text-xs font-bold px-3 py-1 rounded-full shadow-md">
                                    {{ $menu->category->name }}
                                </div>
                            </div>

                            {{-- 2. Informasi Menu --}}
                            <div class="p-5">
                                <div class="flex justify-between items-start mb-2">
                                    <h4 class="font-bold text-xl text-gray-800 dark:text-white line-clamp-1" title="{{ $menu->name }}">
                                        {{ $menu->name }}
                                    </h4>
                                </div>
                                
                                <p class="text-sm text-gray-600 dark:text-gray-300 mb-4 line-clamp-2 min-h-[40px]">
                                    {{ $menu->description }}
                                </p>

                                <div class="flex justify-between items-center pt-4 border-t border-gray-100 dark:border-gray-600">
                                    <div class="text-lg font-extrabold text-indigo-600 dark:text-indigo-400">
                                        Rp {{ number_format($menu->price, 0, ',', '.') }}
                                    </div>
                                    
                                    {{-- Tombol Pesan (Dummy dulu) --}}
                                    <button class="bg-gray-900 dark:bg-white text-white dark:text-gray-900 p-2 rounded-lg hover:bg-indigo-600 dark:hover:bg-indigo-400 transition-colors">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    @empty
                        <div class="col-span-full text-center py-12">
                            <div class="text-gray-400 mb-4">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                                </svg>
                            </div>
                            <p class="text-lg text-gray-500">Belum ada menu yang tersedia saat ini.</p>
                        </div>
                    @endforelse
                </div>

            </div>
        </div>
    </div>
</x-app-layout>
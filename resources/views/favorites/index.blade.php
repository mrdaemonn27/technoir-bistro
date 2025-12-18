<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Menu Favorit Saya') }}
        </h2>
    </x-slot>

    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">

                    @if (session('success'))
                        <div class="mb-4 text-sm text-green-700 bg-green-100 border border-green-300 rounded px-4 py-2">
                            {{ session('success') }}
                        </div>
                    @endif

                    @if ($favorites->isEmpty())
                        <div class="text-center py-12">
                            <h3 class="text-xl font-bold mb-2">Belum ada menu favorit</h3>
                            <p class="text-gray-500 mb-4">Temukan menu favoritmu dan klik ikon hati untuk menyimpannya di sini.</p>
                            <a href="{{ route('menu.index') }}" class="inline-flex items-center px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-full shadow">
                                Lihat Menu
                            </a>
                        </div>
                    @else
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            @foreach ($favorites as $favorite)
                                @php
                                    $menu = $favorite->menu;
                                @endphp
                                @if($menu)
                                    <div class="bg-white dark:bg-gray-900 rounded-xl shadow-md overflow-hidden border border-gray-100 dark:border-gray-700">
                                        <div class="h-40 w-full bg-gray-200 relative overflow-hidden">
                                            @if($menu->image)
                                                <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}"
                                                     alt="{{ $menu->name }}"
                                                     class="w-full h-full object-cover">
                                            @else
                                                <img src="https://placehold.co/600x400/1a202c/FFF?text={{ urlencode($menu->name) }}"
                                                     alt="{{ $menu->name }}"
                                                     class="w-full h-full object-cover">
                                            @endif
                                        </div>

                                        <div class="p-4">
                                            <div class="flex justify-between items-start mb-2">
                                                <h3 class="font-bold text-lg">{{ $menu->name }}</h3>
                                                <form action="{{ route('favorites.destroy', $favorite->id) }}" method="POST">
                                                    @csrf
                                                    @method('DELETE')
                                                    <button type="submit" class="text-red-500 hover:text-red-700" title="Hapus dari favorit">
                                                        &hearts;
                                                    </button>
                                                </form>
                                            </div>
                                            <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ $menu->description }}</p>
                                            <div class="flex justify-between items-center">
                                                <span class="font-bold text-[#E5A024]">
                                                    Rp {{ number_format($menu->price, 0, ',', '.') }}
                                                </span>
                                                @if($menu->availability)
                                                    <span class="px-3 py-1 rounded-full text-xs font-bold bg-green-100 text-green-800">
                                                        Tersedia
                                                    </span>
                                                @else
                                                    <span class="px-3 py-1 rounded-full text-xs font-bold bg-red-100 text-red-800">
                                                        Habis
                                                    </span>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                @endif
                            @endforeach
                        </div>
                    @endif

                </div>
            </div>
        </div>
    </div>
</x-app-layout>



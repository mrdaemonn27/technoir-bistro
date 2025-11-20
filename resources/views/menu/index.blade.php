<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            Technoir Bistro Menu
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        
                        @forelse ($menus as $menu)
                            <div class="bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg overflow-hidden shadow-lg">
                                <img src="https://via.placeholder.com/300x200?text={{ $menu->name }}" alt="{{ $menu->name }}" class="w-full h-48 object-cover">
                                
                                <div class="p-4">
                                    <h3 class="font-bold text-lg mb-2">{{ $menu->name }}</h3>
                                    <p class="text-gray-600 dark:text-gray-400 text-sm mb-4 h-20 overflow-auto">{{ $menu->description }}</p>
                                    
                                    <div class="flex justify-between items-center mt-4">
                                        <span class="font-bold text-blue-600 dark:text-blue-400 text-xl">
                                            Rp {{ number_format($menu->price, 0, ',', '.') }}
                                        </span>
                                        <a href="#" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full transition duration-300">
                                            Pesan
                                        </a>
                                    </div>
                                </div>
                            </div>
                        @empty
                            <p class="col-span-3 text-center">Belum ada menu yang tersedia saat ini.</p>
                        @endforelse
                        
                    </div>

                </div>
            </div>
        </div>
    </div>
</x-app-layout>
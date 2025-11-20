<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
                {{ __('Kelola Menu') }}
            </h2>
            <a href="{{ route('admin.menus.create') }}" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 px-4 rounded">
                + Tambah Menu
            </a>
        </div>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            {{-- Pesan Sukses --}}
            @if(session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4">
                    {{ session('success') }}
                </div>
            @endif

            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="overflow-x-auto">
                    <table class="min-w-full text-left text-sm font-light">
                        <thead class="border-b bg-gray-50 dark:bg-gray-700 dark:text-white">
                            <tr>
                                <th class="px-6 py-4">Gambar</th>
                                <th class="px-6 py-4">Nama</th>
                                <th class="px-6 py-4">Kategori</th>
                                <th class="px-6 py-4">Harga</th>
                                <th class="px-6 py-4">Status</th>
                                <th class="px-6 py-4">Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($menus as $menu)
                            <tr class="border-b dark:border-gray-700 text-gray-800 dark:text-gray-300">
                                <td class="px-6 py-4">
                                    @if($menu->image)
                                        {{-- Cek apakah ini URL (seeder) atau File Upload (storage) --}}
                                        <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                             class="w-16 h-16 object-cover rounded-lg">
                                    @else
                                        <span class="text-gray-400 italic">No Image</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 font-bold">{{ $menu->name }}</td>
                                <td class="px-6 py-4">{{ $menu->category->name }}</td>
                                <td class="px-6 py-4">Rp {{ number_format($menu->price, 0, ',', '.') }}</td>
                                <td class="px-6 py-4">
                                    <span class="px-2 rounded-full text-xs font-semibold {{ $menu->availability ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' }}">
                                        {{ $menu->availability ? 'Tersedia' : 'Habis' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 flex gap-2">
                                    <a href="{{ route('admin.menus.edit', $menu) }}" class="text-yellow-500 hover:text-yellow-700 font-bold">Edit</a>
                                    <form action="{{ route('admin.menus.destroy', $menu) }}" method="POST" onsubmit="return confirm('Hapus menu ini?');">
                                        @csrf @method('DELETE')
                                        <button class="text-red-500 hover:text-red-700 font-bold">Hapus</button>
                                    </form>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
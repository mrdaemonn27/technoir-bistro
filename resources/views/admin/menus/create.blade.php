<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Tambah Menu Baru') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-3xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg p-6">
                
                {{-- PENTING: enctype="multipart/form-data" agar bisa upload file --}}
                <form action="{{ route('admin.menus.store') }}" method="POST" enctype="multipart/form-data">
                    @csrf

                    <div class="mb-4">
                        <x-input-label for="name" :value="__('Nama Menu')" />
                        <x-text-input id="name" class="block mt-1 w-full" type="text" name="name" required />
                    </div>

                    <div class="mb-4">
                        <x-input-label for="category_id" :value="__('Kategori')" />
                        <select name="category_id" class="block mt-1 w-full border-gray-300 dark:bg-gray-900 dark:text-white rounded-md shadow-sm">
                            @foreach($categories as $cat)
                                <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                            @endforeach
                        </select>
                    </div>

                    <div class="mb-4">
                        <x-input-label for="price" :value="__('Harga (Rp)')" />
                        <x-text-input id="price" class="block mt-1 w-full" type="number" name="price" required />
                    </div>

                    <div class="mb-4">
                        <x-input-label for="description" :value="__('Deskripsi')" />
                        <textarea name="description" class="block mt-1 w-full border-gray-300 dark:bg-gray-900 dark:text-white rounded-md shadow-sm" rows="3"></textarea>
                    </div>

                    {{-- Input File Gambar --}}
                    <div class="mb-4">
                        <x-input-label for="image" :value="__('Foto Menu')" />
                        <input type="file" name="image" class="block mt-1 w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100">
                    </div>

                    <div class="mb-6">
                        <label class="inline-flex items-center">
                            <input type="checkbox" name="availability" value="1" checked class="rounded text-indigo-600 shadow-sm">
                            <span class="ml-2 text-gray-600 dark:text-gray-400">Menu Tersedia?</span>
                        </label>
                    </div>

                    <div class="flex justify-end">
                        <x-primary-button>{{ __('Simpan') }}</x-primary-button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</x-app-layout>
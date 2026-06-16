<x-app-layout>
    <style>
        .admin-reveal {
            opacity: 0;
            transform: translateY(14px);
            transition: opacity 520ms ease, transform 520ms ease;
        }

        .admin-reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .clean-input {
            width: 100%;
            border-radius: 18px;
            border: 1px solid #ead8c0;
            background: #fffdf9;
            color: #1f1712;
            transition: border-color 180ms ease, box-shadow 180ms ease, background-color 180ms ease;
        }

        .clean-input:focus {
            border-color: #ea8e16;
            box-shadow: 0 0 0 4px rgba(234, 142, 22, .12);
            outline: none;
        }
    </style>

    <div class="min-h-screen bg-[#fbf7f1] text-[#1f1712]">
        <main class="mx-auto max-w-5xl px-6 py-10 lg:px-8">
            <section class="admin-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                <div class="flex flex-col gap-5 md:flex-row md:items-center md:justify-between">
                    <div>
                        <p class="text-xs font-black uppercase tracking-[0.2em] text-[#b76b0c]">Menu Baru</p>
                        <h1 class="mt-2 text-3xl font-black tracking-tight md:text-4xl">Tambah Menu</h1>
                        <p class="mt-3 max-w-2xl text-sm leading-7 text-[#6b5b4c]">
                            Lengkapi informasi menu agar pelanggan bisa melihat detail dan melakukan pemesanan.
                        </p>
                    </div>

                    <a href="{{ route('admin.menus.index') }}" class="inline-flex items-center justify-center rounded-full border border-[#f0dfca] px-5 py-3 text-sm font-black uppercase tracking-[0.14em] text-[#b76b0c] transition hover:border-[#ea8e16] hover:bg-[#fff3df]">
                        Kembali
                    </a>
                </div>
            </section>

            <section class="admin-reveal mt-6 rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                @if ($errors->any())
                    <div class="mb-6 rounded-3xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
                        <p class="font-black">Menu belum bisa disimpan:</p>
                        <ul class="mt-2 list-disc pl-5">
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <form action="{{ route('admin.menus.store') }}" method="POST" enctype="multipart/form-data" class="space-y-5">
                    @csrf

                    <div class="grid grid-cols-1 gap-5 md:grid-cols-2">
                        <div>
                            <x-input-label for="name" :value="__('Nama Menu')" class="text-[#1f1712]" />
                            <input id="name" class="clean-input mt-2 px-4 py-3" type="text" name="name" value="{{ old('name') }}" required />
                            <x-input-error :messages="$errors->get('name')" class="mt-2" />
                        </div>

                        <div>
                            <x-input-label for="category_id" :value="__('Kategori')" class="text-[#1f1712]" />
                            <select id="category_id" name="category_id" required class="clean-input mt-2 px-4 py-3">
                                <option value="" disabled {{ old('category_id') ? '' : 'selected' }}>Pilih kategori</option>
                                @foreach($categories as $cat)
                                    <option value="{{ $cat->id }}" {{ old('category_id') == $cat->id ? 'selected' : '' }}>{{ $cat->name }}</option>
                                @endforeach
                            </select>
                            <x-input-error :messages="$errors->get('category_id')" class="mt-2" />
                        </div>
                    </div>

                    <div>
                        <x-input-label for="price" :value="__('Harga (Rp)')" class="text-[#1f1712]" />
                        <input id="price" class="clean-input mt-2 px-4 py-3" type="number" name="price" value="{{ old('price') }}" min="0" step="1" required />
                        <x-input-error :messages="$errors->get('price')" class="mt-2" />
                    </div>

                    <div>
                        <x-input-label for="description" :value="__('Deskripsi')" class="text-[#1f1712]" />
                        <textarea id="description" name="description" class="clean-input mt-2 px-4 py-3" rows="4">{{ old('description') }}</textarea>
                        <x-input-error :messages="$errors->get('description')" class="mt-2" />
                    </div>

                    <div class="rounded-3xl border border-dashed border-[#e8d5bd] bg-[#fffdf9] p-5">
                        <x-input-label for="image" :value="__('Foto Menu')" class="text-[#1f1712]" />
                        <input id="image" type="file" name="image" class="mt-3 block w-full text-sm text-[#6b5b4c] file:mr-4 file:rounded-full file:border-0 file:bg-[#fff3df] file:px-4 file:py-2 file:text-sm file:font-black file:text-[#b76b0c] hover:file:bg-[#ffe5bd]">
                        <x-input-error :messages="$errors->get('image')" class="mt-2" />
                    </div>

                    <label class="inline-flex items-center gap-3 rounded-full border border-[#f0dfca] bg-[#fffdf9] px-4 py-3">
                        <input type="checkbox" name="availability" value="1" checked class="rounded border-[#e8d5bd] text-[#ea8e16] shadow-sm focus:ring-[#ea8e16]">
                        <span class="text-sm font-semibold text-[#6b5b4c]">Menu Tersedia?</span>
                    </label>

                    <div class="flex justify-end">
                        <button type="submit" class="rounded-full bg-[#ea8e16] px-6 py-3 text-sm font-black uppercase tracking-[0.14em] text-white shadow-sm transition hover:-translate-y-0.5 hover:bg-[#c8740f]">
                            Simpan
                        </button>
                    </div>
                </form>
            </section>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.admin-reveal').forEach((item, index) => {
                item.style.transitionDelay = `${Math.min(index * 70, 220)}ms`;
                requestAnimationFrame(() => item.classList.add('is-visible'));
            });
        });
    </script>
</x-app-layout>
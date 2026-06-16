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

        .soft-row,
        .soft-card {
            transition: transform 200ms ease, background-color 200ms ease, box-shadow 200ms ease, border-color 200ms ease;
        }

        .soft-row:hover {
            background-color: #fffaf2;
        }

        .soft-card:hover {
            transform: translateY(-3px);
            border-color: rgba(234, 142, 22, .36);
            box-shadow: 0 16px 38px rgba(117, 74, 25, .08);
        }

        @media (prefers-reduced-motion: reduce) {
            .admin-reveal,
            .soft-row,
            .soft-card {
                transition: none;
                transform: none;
            }
        }
    </style>

    <div class="min-h-screen bg-[#fbf7f1] text-[#1f1712]">
        <main class="mx-auto max-w-7xl px-6 py-10 lg:px-8">
            <section class="admin-reveal flex flex-col gap-5 rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm md:flex-row md:items-center md:justify-between">
                <div>
                    <p class="text-xs font-black uppercase tracking-[0.2em] text-[#b76b0c]">Admin Menu</p>
                    <h1 class="mt-2 text-3xl font-black tracking-tight md:text-4xl">Kelola Menu</h1>
                    <p class="mt-3 max-w-2xl text-sm leading-7 text-[#6b5b4c]">
                        Atur daftar makanan dan minuman, harga, kategori, foto, dan status ketersediaan menu.
                    </p>
                </div>

                <a href="{{ route('admin.menus.create') }}" class="inline-flex items-center justify-center rounded-full bg-[#ea8e16] px-5 py-3 text-sm font-black uppercase tracking-[0.14em] text-white shadow-sm transition hover:-translate-y-0.5 hover:bg-[#c8740f]">
                    + Tambah Menu
                </a>
            </section>

            @if(session('success'))
                <div class="admin-reveal mt-6 rounded-3xl border border-green-200 bg-green-50 px-5 py-4 text-sm font-semibold text-green-700">
                    {{ session('success') }}
                </div>
            @endif

            <section class="admin-reveal mt-6 overflow-hidden rounded-[28px] border border-[#f0dfca] bg-white shadow-sm">
                <div class="border-b border-[#f3e5d3] px-6 py-5">
                    <h2 class="text-lg font-black">Daftar Menu</h2>
                    <p class="mt-1 text-sm text-[#6b5b4c]">Gunakan aksi edit atau hapus untuk memperbarui data menu.</p>
                </div>

                <div class="overflow-x-auto">
                    <table class="min-w-full text-left text-sm">
                        <thead class="bg-[#fff8ed] text-xs font-black uppercase tracking-[0.14em] text-[#9b8067]">
                            <tr>
                                <th class="px-6 py-4">Gambar</th>
                                <th class="px-6 py-4">Nama</th>
                                <th class="px-6 py-4">Kategori</th>
                                <th class="px-6 py-4">Harga</th>
                                <th class="px-6 py-4">Status</th>
                                <th class="px-6 py-4 text-right">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-[#f3e5d3]">
                            @forelse ($menus as $menu)
                                <tr class="soft-row align-middle">
                                    <td class="px-6 py-4">
                                        @if($menu->image)
                                            <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}"
                                                 class="h-16 w-16 rounded-2xl object-cover shadow-sm"
                                                 alt="{{ $menu->name }}">
                                        @else
                                            <div class="flex h-16 w-16 items-center justify-center rounded-2xl border border-dashed border-[#e8d5bd] bg-[#fffdf9] text-xs font-semibold text-[#a89583]">
                                                No Image
                                            </div>
                                        @endif
                                    </td>
                                    <td class="px-6 py-4">
                                        <p class="font-black text-[#1f1712]">{{ $menu->name }}</p>
                                        <p class="mt-1 line-clamp-1 max-w-xs text-xs text-[#6b5b4c]">{{ $menu->description ?: 'Tidak ada deskripsi.' }}</p>
                                    </td>
                                    <td class="px-6 py-4 text-[#6b5b4c]">{{ $menu->category->name ?? '-' }}</td>
                                    <td class="px-6 py-4 font-black text-[#1f1712]">Rp {{ number_format($menu->price, 0, ',', '.') }}</td>
                                    <td class="px-6 py-4">
                                        <span class="rounded-full px-3 py-1 text-xs font-black uppercase tracking-[0.1em] {{ $menu->availability ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700' }}">
                                            {{ $menu->availability ? 'Tersedia' : 'Habis' }}
                                        </span>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="flex justify-end gap-2">
                                            <a href="{{ route('admin.menus.edit', $menu) }}" class="rounded-full border border-[#f0dfca] px-4 py-2 text-xs font-black uppercase tracking-[0.12em] text-[#b76b0c] transition hover:border-[#ea8e16] hover:bg-[#fff3df]">
                                                Edit
                                            </a>
                                            <form action="{{ route('admin.menus.destroy', $menu) }}" method="POST" onsubmit="return confirm('Hapus menu ini?');">
                                                @csrf
                                                @method('DELETE')
                                                <button class="rounded-full border border-red-100 px-4 py-2 text-xs font-black uppercase tracking-[0.12em] text-red-600 transition hover:bg-red-50">
                                                    Hapus
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="px-6 py-12 text-center text-sm text-[#6b5b4c]">
                                        Belum ada menu yang ditambahkan.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const items = document.querySelectorAll('.admin-reveal');

            if ('IntersectionObserver' in window) {
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach((entry) => {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('is-visible');
                            observer.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.12 });

                items.forEach((item, index) => {
                    item.style.transitionDelay = `${Math.min(index * 55, 280)}ms`;
                    observer.observe(item);
                });
            } else {
                items.forEach((item) => item.classList.add('is-visible'));
            }
        });
    </script>
</x-app-layout>
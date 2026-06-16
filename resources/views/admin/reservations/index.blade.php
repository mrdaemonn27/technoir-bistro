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

        .soft-row {
            transition: background-color 200ms ease, transform 200ms ease;
        }

        .soft-row:hover {
            background-color: #fffaf2;
        }

        .status-select {
            border-radius: 999px;
            border: 1px solid #ead8c0;
            background: #fffdf9;
            padding: .5rem .85rem;
            font-size: .75rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .08em;
        }

        .status-select:focus {
            border-color: #ea8e16;
            box-shadow: 0 0 0 4px rgba(234, 142, 22, .12);
            outline: none;
        }
    </style>

    <div class="min-h-screen bg-[#fbf7f1] text-[#1f1712]">
        <main class="mx-auto max-w-7xl px-6 py-10 lg:px-8">
            <section class="admin-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                <p class="text-xs font-black uppercase tracking-[0.2em] text-[#b76b0c]">Admin Reservasi</p>
                <h1 class="mt-2 text-3xl font-black tracking-tight md:text-4xl">Reservasi Masuk</h1>
                <p class="mt-3 max-w-2xl text-sm leading-7 text-[#6b5b4c]">
                    Pantau jadwal kedatangan, meja, jumlah tamu, pesanan menu, dan perbarui status reservasi.
                </p>
            </section>

            @if(session('success'))
                <div class="admin-reveal mt-6 rounded-3xl border border-green-200 bg-green-50 px-5 py-4 text-sm font-semibold text-green-700">
                    {{ session('success') }}
                </div>
            @endif

            @if(session('warning'))
                <div class="admin-reveal mt-6 rounded-3xl border border-yellow-200 bg-yellow-50 px-5 py-4 text-sm font-semibold text-yellow-700">
                    {{ session('warning') }}
                </div>
            @endif

            <section class="admin-reveal mt-6 overflow-hidden rounded-[28px] border border-[#f0dfca] bg-white shadow-sm">
                <div class="border-b border-[#f3e5d3] px-6 py-5">
                    <h2 class="text-lg font-black">Daftar Reservasi</h2>
                    <p class="mt-1 text-sm text-[#6b5b4c]">Status akan tersimpan otomatis saat pilihan diubah.</p>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead class="bg-[#fff8ed] text-xs font-black uppercase tracking-[0.14em] text-[#9b8067]">
                            <tr>
                                <th class="px-6 py-4">ID</th>
                                <th class="px-6 py-4">Pemesan</th>
                                <th class="px-6 py-4">Jadwal</th>
                                <th class="px-6 py-4">Meja & Pesanan</th>
                                <th class="px-6 py-4">Status</th>
                                <th class="px-6 py-4 text-right">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-[#f3e5d3]">
                            @forelse ($reservations as $reservation)
                                <tr class="soft-row align-top">
                                    <td class="px-6 py-5 font-black text-[#1f1712]">#{{ $reservation->id }}</td>
                                    <td class="px-6 py-5">
                                        <p class="font-black text-[#1f1712]">{{ $reservation->user->username ?? 'Guest' }}</p>
                                        <p class="mt-1 text-xs text-[#8c7b68]">{{ $reservation->user->email ?? '-' }}</p>
                                    </td>
                                    <td class="px-6 py-5">
                                        <p class="font-semibold text-[#1f1712]">{{ \Carbon\Carbon::parse($reservation->reservation_date)->format('d M Y') }}</p>
                                        <p class="mt-1 text-sm font-black text-[#b76b0c]">{{ \Carbon\Carbon::parse($reservation->reservation_date)->format('H:i') }}</p>
                                    </td>
                                    <td class="px-6 py-5">
                                        <p class="font-semibold text-[#1f1712]">
                                            {{ $reservation->table->no_meja ?? $reservation->table->table_number ?? $reservation->table->nomor_meja ?? $reservation->table->name ?? 'Meja Dihapus' }}
                                            <span class="text-xs font-normal text-[#8c7b68]">({{ $reservation->table->location ?? '-' }})</span>
                                        </p>
                                        <p class="mt-1 text-xs text-[#6b5b4c]">{{ $reservation->guest_count }} Orang</p>

                                        @if($reservation->menus->count() > 0)
                                            <div class="mt-3 rounded-2xl bg-[#fff8ed] p-3 text-xs">
                                                <p class="mb-2 font-black text-[#1f1712]">Pesanan Menu</p>
                                                <ul class="space-y-2">
                                                    @foreach($reservation->menus as $menu)
                                                        <li class="flex justify-between gap-4">
                                                            <span>{{ $menu->name }} <span class="text-[#8c7b68]">(x{{ $menu->pivot->quantity }})</span></span>
                                                            <span class="font-black">Rp {{ number_format($menu->price * $menu->pivot->quantity, 0, ',', '.') }}</span>
                                                        </li>
                                                    @endforeach
                                                </ul>
                                            </div>
                                        @else
                                            <p class="mt-3 text-xs italic text-[#8c7b68]">Tidak ada pesanan menu.</p>
                                        @endif
                                    </td>
                                    <td class="px-6 py-5">
                                        <form action="{{ route('admin.reservations.update', $reservation->id) }}" method="POST">
                                            @csrf
                                            @method('PUT')
                                            <select name="status" onchange="this.form.submit()" class="status-select
                                                {{ $reservation->status === 'confirmed' ? 'text-green-700' : '' }}
                                                {{ $reservation->status === 'cancelled' ? 'text-red-700' : '' }}
                                                {{ $reservation->status === 'pending' ? 'text-[#b76b0c]' : '' }}">
                                                <option value="pending" {{ $reservation->status == 'pending' ? 'selected' : '' }}>Pending</option>
                                                <option value="confirmed" {{ $reservation->status == 'confirmed' ? 'selected' : '' }}>Confirmed</option>
                                                <option value="completed" {{ $reservation->status == 'completed' ? 'selected' : '' }}>Completed</option>
                                                <option value="cancelled" {{ $reservation->status == 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                                            </select>
                                        </form>
                                    </td>
                                    <td class="px-6 py-5 text-right">
                                        <form action="{{ route('admin.reservations.destroy', $reservation->id) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin menghapus reservasi ini?');" class="inline-block">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="rounded-full border border-red-100 px-4 py-2 text-xs font-black uppercase tracking-[0.12em] text-red-600 transition hover:bg-red-50">
                                                Hapus
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="px-6 py-12 text-center text-sm text-[#6b5b4c]">
                                        Belum ada reservasi masuk.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="border-t border-[#f3e5d3] px-6 py-5">
                    {{ $reservations->links() }}
                </div>
            </section>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.admin-reveal').forEach((item, index) => {
                item.style.transitionDelay = `${Math.min(index * 55, 280)}ms`;
                requestAnimationFrame(() => item.classList.add('is-visible'));
            });
        });
    </script>
</x-app-layout>
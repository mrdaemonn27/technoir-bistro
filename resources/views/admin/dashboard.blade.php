<x-app-layout>
    <style>
        .admin-reveal {
            opacity: 0;
            transform: translateY(16px);
            transition: opacity 560ms ease, transform 560ms ease;
        }

        .admin-reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .soft-card {
            transition: transform 220ms ease, border-color 220ms ease, box-shadow 220ms ease, background-color 220ms ease;
        }

        .soft-card:hover {
            transform: translateY(-4px);
            border-color: rgba(234, 142, 22, 0.38);
            box-shadow: 0 18px 45px rgba(117, 74, 25, 0.10);
        }

        .pulse-dot {
            animation: pulseDot 1.8s ease-in-out infinite;
        }

        @keyframes pulseDot {
            0%, 100% {
                transform: scale(1);
                opacity: .65;
            }
            50% {
                transform: scale(1.5);
                opacity: 1;
            }
        }

        .float-logo {
            animation: floatLogo 4.5s ease-in-out infinite;
        }

        @keyframes floatLogo {
            0%, 100% {
                transform: translateY(0);
            }
            50% {
                transform: translateY(-6px);
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .admin-reveal,
            .soft-card,
            .pulse-dot,
            .float-logo {
                animation: none;
                transition: none;
                transform: none;
            }
        }
    </style>

    <div class="min-h-screen bg-[#fbf7f1] text-[#1f1712]">
        <main class="mx-auto max-w-7xl px-6 py-10 lg:px-8">
            <section class="admin-reveal overflow-hidden rounded-[28px] border border-[#f0dfca] bg-white shadow-sm">
                <div class="p-7 md:p-9">
                    <div>
                        <div class="inline-flex items-center gap-2 rounded-full border border-[#f1d8b8] bg-[#fff8ed] px-3 py-1.5 text-xs font-bold uppercase tracking-[0.18em] text-[#b76b0c]">
                            <span class="pulse-dot h-2 w-2 rounded-full bg-[#ea8e16]"></span>
                            Main Control
                        </div>
                        <h1 class="mt-5 max-w-3xl text-3xl font-black leading-tight tracking-tight text-[#1f1712] md:text-5xl">
                            Dashboard Administrator
                        </h1>
                        <p class="mt-4 max-w-2xl text-base leading-8 text-[#6b5b4c]">
                            Selamat datang, {{ Auth::user()->username }}. Semua ringkasan operasional restoran tersusun rapi di satu tempat.
                        </p>
                    </div>
                </div>
            </section>

            <section class="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
                @foreach([
                    ['label' => 'Total Menu', 'value' => $stats['menus'] ?? 0, 'meta' => ($stats['availableMenus'] ?? 0) . ' tersedia', 'icon' => 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253'],
                    ['label' => 'Reservasi', 'value' => $stats['reservations'] ?? 0, 'meta' => ($stats['pendingReservations'] ?? 0) . ' pending', 'icon' => 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'],
                    ['label' => 'Pendapatan', 'value' => 'Rp ' . number_format($stats['revenue'] ?? 0, 0, ',', '.'), 'meta' => 'total tercatat', 'icon' => 'M12 8c-2.21 0-4 1.343-4 3s1.79 3 4 3 4-1.343 4-3-1.79-3-4-3z M3 11c2.4-4 5.4-6 9-6s6.6 2 9 6c-2.4 4-5.4 6-9 6s-6.6-2-9-6z'],
                    ['label' => 'Status Sistem', 'value' => 'Aktif', 'meta' => 'operasional', 'icon' => 'M13 10V3L4 14h7v7l9-11h-7z'],
                ] as $stat)
                    <article class="admin-reveal soft-card rounded-3xl border border-[#f0dfca] bg-white p-5">
                        <div class="flex items-center justify-between gap-4">
                            <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#fff3df] text-[#c8740f]">
                                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{{ $stat['icon'] }}" />
                                </svg>
                            </div>
                            <p class="text-xs font-bold uppercase tracking-[0.16em] text-[#a89583]">{{ $stat['label'] }}</p>
                        </div>
                        <p class="mt-5 text-3xl font-black tracking-tight text-[#1f1712]">{{ $stat['value'] }}</p>
                        <p class="mt-1 text-sm text-[#6b5b4c]">{{ $stat['meta'] }}</p>
                    </article>
                @endforeach
            </section>

            <section class="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-[1fr_360px]">
                <div class="admin-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6">
                    <div class="flex flex-col gap-2 border-b border-[#f3e5d3] pb-5 sm:flex-row sm:items-end sm:justify-between">
                        <div>
                            <p class="text-xs font-black uppercase tracking-[0.2em] text-[#b76b0c]">Quick Actions</p>
                            <h2 class="mt-2 text-2xl font-black tracking-tight text-[#1f1712]">Akses cepat admin</h2>
                        </div>
                        <p class="max-w-md text-sm leading-6 text-[#6b5b4c]">Pilih modul utama untuk mengelola operasional harian.</p>
                    </div>

                    <div class="mt-5 grid grid-cols-1 gap-4 md:grid-cols-3">
                        @foreach([
                            ['title' => 'Kelola Menu', 'desc' => 'Tambah dan ubah makanan atau minuman.', 'route' => route('admin.menus.index'), 'icon' => 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253'],
                            ['title' => 'Reservasi', 'desc' => 'Pantau meja dan pesanan pelanggan.', 'route' => route('admin.reservations.index'), 'icon' => 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'],
                            ['title' => 'Laporan', 'desc' => 'Lihat pendapatan dan transaksi.', 'route' => route('admin.reports.index'), 'icon' => 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z'],
                        ] as $action)
                            <a href="{{ $action['route'] }}" class="soft-card group rounded-3xl border border-[#f0dfca] bg-[#fffdf9] p-5">
                                <div class="flex items-center justify-between">
                                    <div class="flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-[#c8740f] shadow-sm transition group-hover:bg-[#ea8e16] group-hover:text-white">
                                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{{ $action['icon'] }}" />
                                        </svg>
                                    </div>
                                    <span class="text-lg text-[#cdb8a1] transition group-hover:translate-x-1 group-hover:text-[#c8740f]">-></span>
                                </div>
                                <h3 class="mt-5 text-lg font-black text-[#1f1712]">{{ $action['title'] }}</h3>
                                <p class="mt-2 text-sm leading-6 text-[#6b5b4c]">{{ $action['desc'] }}</p>
                            </a>
                        @endforeach
                    </div>
                </div>

                <aside class="admin-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6">
                    <div class="flex items-center justify-between gap-4 border-b border-[#f3e5d3] pb-5">
                        <div>
                            <p class="text-xs font-black uppercase tracking-[0.2em] text-[#b76b0c]">Terbaru</p>
                            <h2 class="mt-2 text-2xl font-black tracking-tight">Reservasi</h2>
                        </div>
                        <a href="{{ route('admin.reservations.index') }}" class="rounded-full border border-[#f0dfca] px-3 py-2 text-xs font-black uppercase tracking-[0.12em] text-[#b76b0c] transition hover:border-[#ea8e16] hover:bg-[#fff3df]">
                            Semua
                        </a>
                    </div>

                    <div class="mt-5 space-y-3">
                        @forelse($recentReservations as $reservation)
                            <div class="admin-reveal rounded-3xl border border-[#f0dfca] bg-[#fffdf9] p-4">
                                <div class="flex items-start justify-between gap-4">
                                    <div>
                                        <p class="font-black text-[#1f1712]">{{ $reservation->user->username ?? 'Tamu' }}</p>
                                        <p class="mt-1 text-sm text-[#6b5b4c]">
                                            {{ optional($reservation->reservation_date)->format('d M Y, H:i') }}
                                        </p>
                                    </div>
                                    <span class="rounded-full px-3 py-1 text-xs font-black uppercase tracking-[0.1em] {{ $reservation->status === 'pending' ? 'bg-[#fff3df] text-[#b76b0c]' : 'bg-green-50 text-green-700' }}">
                                        {{ $reservation->status }}
                                    </span>
                                </div>
                                <p class="mt-3 text-sm text-[#6b5b4c]">Meja {{ $reservation->table->table_number ?? '-' }} | {{ $reservation->guest_count }} tamu</p>
                            </div>
                        @empty
                            <div class="rounded-3xl border border-dashed border-[#e8d5bd] bg-[#fffdf9] p-6 text-center text-sm text-[#6b5b4c]">
                                Belum ada reservasi terbaru.
                            </div>
                        @endforelse
                    </div>
                </aside>
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
                    item.style.transitionDelay = `${Math.min(index * 45, 300)}ms`;
                    observer.observe(item);
                });
            } else {
                items.forEach((item) => item.classList.add('is-visible'));
            }
        });
    </script>
</x-app-layout>
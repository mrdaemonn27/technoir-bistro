<x-app-layout>
    <style>
        .home-shell {
            background: #1b120c;
            color: #f8fafc;
            overflow: hidden;
            --brand-orange: #e5a024;
            --brand-orange-soft: #f4c46b;
            --brand-orange-dark: #b87912;
            --brand-cream: #fff7ea;
            --brand-espresso: #1b120c;
            --brand-card: #2a1c13;
        }

        .hero-stage {
            min-height: calc(100vh - 76px);
            background-image:
                linear-gradient(90deg, rgba(27, 18, 12, 0.92) 0%, rgba(27, 18, 12, 0.72) 45%, rgba(27, 18, 12, 0.42) 100%),
                url("{{ asset('images/hero-restaurant-view.png') }}");
            background-size: cover;
            background-position: center 48%;
        }

        .soft-grid {
            background-image:
                linear-gradient(rgba(255, 255, 255, 0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.07) 1px, transparent 1px);
            background-size: 56px 56px;
            mask-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.7), transparent 75%);
        }

        .warm-section {
            background:
                linear-gradient(135deg, rgba(255, 247, 234, 0.98) 0%, rgba(255, 241, 218, 0.96) 48%, rgba(255, 228, 184, 0.88) 100%);
        }

        .cream-section {
            background:
                linear-gradient(145deg, #fffaf2 0%, #fff3dd 55%, #ffe7bf 100%);
        }

        .espresso-section {
            background:
                radial-gradient(circle at top left, rgba(229, 160, 36, 0.16), transparent 34%),
                linear-gradient(145deg, #1b120c 0%, #26170f 58%, #120c08 100%);
        }

        .gradient-text {
            background: linear-gradient(100deg, #ffffff 0%, #ffe9bd 38%, #e5a024 78%, #fff7ea 100%);
            background-size: 180% 180%;
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            animation: gradient-drift 8s ease-in-out infinite;
        }

        .gradient-heading {
            background: linear-gradient(100deg, #24170f 0%, #8f5d13 48%, #e5a024 100%);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .gradient-button {
            position: relative;
            isolation: isolate;
            overflow: hidden;
            background: linear-gradient(135deg, #ffd36f 0%, #e5a024 42%, #b87912 100%);
            box-shadow: 0 18px 44px rgba(184, 121, 18, 0.28);
        }

        .gradient-button::after {
            content: "";
            position: absolute;
            inset: 0;
            z-index: -1;
            background: linear-gradient(100deg, transparent 0%, rgba(255, 255, 255, 0.42) 45%, transparent 70%);
            transform: translateX(-120%);
            transition: transform 650ms ease;
        }

        .gradient-button:hover::after {
            transform: translateX(120%);
        }

        .accent-pill {
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, rgba(27, 18, 12, 0.74), rgba(69, 42, 22, 0.72));
        }

        .accent-pill::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, transparent, rgba(244, 196, 107, 0.18), transparent);
            transform: translateX(-100%);
            animation: soft-sheen 4.5s ease-in-out infinite;
        }

        .glow-card {
            position: relative;
            overflow: hidden;
        }

        .glow-card::before {
            content: "";
            position: absolute;
            inset: 0;
            pointer-events: none;
            background: linear-gradient(135deg, rgba(229, 160, 36, 0.18), transparent 44%, rgba(255, 255, 255, 0.26));
            opacity: 0;
            transition: opacity 260ms ease;
        }

        .glow-card:hover::before {
            opacity: 1;
        }

        .image-lift {
            animation: image-lift 6.5s ease-in-out infinite;
        }

        .reveal {
            opacity: 0;
            transform: translateY(22px);
            transition: opacity 700ms ease, transform 700ms ease;
        }

        .reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .float-slow {
            animation: float-slow 5.5s ease-in-out infinite;
        }

        .pulse-line {
            animation: pulse-line 2.8s ease-in-out infinite;
        }

        .marquee-track {
            animation: marquee 24s linear infinite;
        }

        .magnetic-card {
            transition: transform 260ms ease, border-color 260ms ease, box-shadow 260ms ease;
        }

        .magnetic-card:hover {
            transform: translateY(-8px);
            border-color: rgba(229, 160, 36, 0.72);
            box-shadow: 0 22px 70px rgba(0, 0, 0, 0.35);
        }

        .testimonial-track {
            animation: testimonial-shift 12s ease-in-out infinite;
        }

        @keyframes float-slow {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-14px); }
        }

        @keyframes gradient-drift {
            0%, 100% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
        }

        @keyframes soft-sheen {
            0%, 35% { transform: translateX(-100%); }
            65%, 100% { transform: translateX(100%); }
        }

        @keyframes image-lift {
            0%, 100% { transform: translateY(0) scale(1); }
            50% { transform: translateY(-8px) scale(1.015); }
        }

        @keyframes pulse-line {
            0%, 100% { opacity: 0.45; transform: scaleX(0.72); }
            50% { opacity: 1; transform: scaleX(1); }
        }

        @keyframes marquee {
            from { transform: translateX(0); }
            to { transform: translateX(-50%); }
        }

        @keyframes testimonial-shift {
            0%, 26% { transform: translateX(0); }
            33%, 59% { transform: translateX(-33.333%); }
            66%, 92% { transform: translateX(-66.666%); }
            100% { transform: translateX(0); }
        }

        @media (prefers-reduced-motion: reduce) {
            .reveal,
            .float-slow,
            .pulse-line,
            .marquee-track,
            .testimonial-track,
            .gradient-text,
            .accent-pill::after,
            .image-lift,
            .magnetic-card {
                animation: none;
                transition: none;
                transform: none;
            }
        }
    </style>

    <div class="home-shell">
        <section class="hero-stage relative flex items-center">
            <div class="soft-grid absolute inset-0"></div>
            <div class="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-[#1b120c] to-transparent"></div>

            <div class="relative z-10 mx-auto grid max-w-7xl grid-cols-1 items-center gap-12 px-6 py-20 lg:grid-cols-[1.05fr_0.95fr] lg:px-8">
                <div class="reveal">
                    <div class="accent-pill mb-6 inline-flex items-center gap-3 rounded-full border border-[#e5a024]/40 px-4 py-2 text-xs font-bold uppercase tracking-[0.28em] text-[#f4c46b] backdrop-blur">
                        <span class="h-2 w-2 rounded-full bg-[#e5a024]"></span>
                        <span class="relative z-10">Bandung Night Dining</span>
                    </div>

                    <h1 class="gradient-text max-w-4xl text-5xl font-black leading-[0.95] tracking-normal sm:text-6xl lg:text-8xl">
                        Technoir Bistro
                    </h1>

                    <div class="mt-9 flex flex-col gap-3 sm:flex-row">
                        <a href="{{ route('reservations.create') }}" class="gradient-button inline-flex items-center justify-center rounded-full px-7 py-4 text-sm font-black uppercase tracking-[0.18em] text-[#24170f] transition hover:-translate-y-0.5">
                            Reservasi
                        </a>
                        <a href="{{ route('menu.index') }}" class="inline-flex items-center justify-center rounded-full border border-white/35 px-7 py-4 text-sm font-black uppercase tracking-[0.18em] text-white transition hover:-translate-y-0.5 hover:border-[#e5a024] hover:text-[#f4c46b]">
                            Lihat Menu
                        </a>
                    </div>

                    <div class="mt-12 grid max-w-xl grid-cols-3 border-y border-white/15 py-5 text-center sm:text-left">
                        <div>
                            <p class="text-3xl font-black text-white">10</p>
                            <p class="mt-1 text-xs uppercase tracking-[0.2em] text-slate-400">Open AM</p>
                        </div>
                        <div class="border-x border-white/15 px-4">
                            <p class="text-3xl font-black text-white">3</p>
                            <p class="mt-1 text-xs uppercase tracking-[0.2em] text-slate-400">Table Zones</p>
                        </div>
                        <div class="pl-4">
                            <p class="text-3xl font-black text-white">24h</p>
                            <p class="mt-1 text-xs uppercase tracking-[0.2em] text-slate-400">Booking</p>
                        </div>
                    </div>
                </div>

                <div class="reveal relative hidden lg:block">
                    <div class="float-slow relative ml-auto w-[420px] rounded-[2rem] border border-orange-200/25 bg-[#fff7ea]/12 p-3 backdrop-blur">
                        <img src="https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=900&q=85" alt="Interior Technoir Bistro" class="image-lift h-[560px] w-full rounded-[1.5rem] object-cover">
                        <div class="absolute bottom-8 left-8 right-8 rounded-2xl border border-orange-200/25 bg-[#1b120c]/84 p-5 backdrop-blur">
                            <div class="flex items-center justify-between gap-4">
                                <div>
                                    <p class="text-xs font-bold uppercase tracking-[0.24em] text-[#f4c46b]">Tonight's Mood</p>
                                    <p class="mt-2 text-2xl font-black text-white">Warm lights, bold plates.</p>
                                </div>
                                <div class="h-12 w-1 origin-left bg-[#e5a024] pulse-line"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="border-y border-orange-200/20 bg-[#2a1c13] py-4">
            <div class="marquee-track flex w-[200%] gap-10 whitespace-nowrap text-sm font-black uppercase tracking-[0.25em] text-[#fff7ea]">
                @for ($i = 0; $i < 2; $i++)
                    <span>Signature Dinner</span>
                    <span class="text-[#e5a024]">Online Reservation</span>
                    <span>Private Table</span>
                    <span class="text-[#e5a024]">Fresh Kitchen</span>
                    <span>Late Night Bistro</span>
                    <span class="text-[#e5a024]">Technoir Experience</span>
                @endfor
            </div>
        </section>

        <section class="warm-section py-24 text-[#24170f]">
            <div class="mx-auto max-w-7xl px-6 lg:px-8">
                <div class="grid grid-cols-1 gap-10 lg:grid-cols-[0.85fr_1.15fr] lg:items-end">
                    <div class="reveal">
                        <p class="text-sm font-black uppercase tracking-[0.28em] text-[#b87912]">Why Visit</p>
                        <h2 class="gradient-heading mt-4 text-4xl font-black sm:text-5xl">Makan malam yang terasa lebih hidup.</h2>
                    </div>
                </div>

                <div class="mt-12 grid grid-cols-1 gap-5 md:grid-cols-3">
                    <article class="reveal magnetic-card glow-card rounded-3xl border border-orange-200 bg-white p-7 shadow-xl shadow-orange-900/5">
                        <div class="mb-7 flex h-12 w-12 items-center justify-center rounded-2xl bg-[#e5a024] text-[#24170f]">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                        </div>
                        <h3 class="text-xl font-black text-[#24170f]">Booking Cepat</h3>
                        <p class="mt-3 leading-7 text-[#6f5136]">Pilih meja, waktu kedatangan, dan pre-order menu langsung dari web.</p>
                    </article>

                    <article class="reveal magnetic-card glow-card rounded-3xl border border-orange-200 bg-[#fffaf2] p-7 shadow-xl shadow-orange-900/5">
                        <div class="mb-7 flex h-12 w-12 items-center justify-center rounded-2xl bg-[#f4c46b] text-[#24170f]">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-2.21 0-4 1.343-4 3 0 1.657 1.79 3 4 3s4-1.343 4-3c0-1.657-1.79-3-4-3z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 11c2.4-4 5.4-6 9-6s6.6 2 9 6c-2.4 4-5.4 6-9 6s-6.6-2-9-6z"/></svg>
                        </div>
                        <h3 class="text-xl font-black text-[#24170f]">Atmosfer Noir</h3>
                        <p class="mt-3 leading-7 text-[#6f5136]">Pencahayaan hangat, detail industrial, dan ruang yang enak untuk ngobrol lama.</p>
                    </article>

                    <article class="reveal magnetic-card glow-card rounded-3xl border border-orange-200 bg-[#fff3dd] p-7 shadow-xl shadow-orange-900/5">
                        <div class="mb-7 flex h-12 w-12 items-center justify-center rounded-2xl bg-[#b87912] text-white">
                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h18M4 8h16M6 13h12M8 18h8"/></svg>
                        </div>
                        <h3 class="text-xl font-black text-[#24170f]">Menu Terpilih</h3>
                        <p class="mt-3 leading-7 text-[#6f5136]">Pilihan makanan dan minuman dibuat ringkas, jelas, dan mudah dipesan.</p>
                    </article>
                </div>
            </div>
        </section>

        <section class="cream-section py-24 text-[#24170f]">
            <div class="mx-auto grid max-w-7xl grid-cols-1 gap-14 px-6 lg:grid-cols-2 lg:px-8">
                <div class="reveal relative">
                    <img src="https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1100&q=85" alt="Chef plating a dish" class="h-[520px] w-full rounded-[2rem] object-cover">
                    <div class="absolute bottom-6 left-6 rounded-2xl border border-white/40 bg-white/90 p-5 shadow-2xl backdrop-blur">
                        <p class="text-xs font-black uppercase tracking-[0.24em] text-[#b87912]">Kitchen Signal</p>
                        <p class="mt-2 text-2xl font-black">Fresh prep, clean finish.</p>
                    </div>
                </div>

                <div class="reveal flex flex-col justify-center">
                    <p class="text-sm font-black uppercase tracking-[0.28em] text-[#b87912]">The Story</p>
                    <h2 class="gradient-heading mt-4 text-4xl font-black sm:text-5xl">Tradisi bistro, ritme kota malam.</h2>
                    <p class="mt-6 text-lg leading-9 text-[#60422b]">
                        Technoir Bistro membawa rasa yang familiar ke ruang yang lebih modern. Cocok untuk dinner santai, kerja ringan, atau kumpul kecil tanpa suasana yang terlalu ramai.
                    </p>

                    <div class="mt-10 grid grid-cols-2 gap-5">
                        <div class="rounded-3xl border border-orange-100 bg-white p-6 shadow-lg shadow-orange-900/5">
                            <p class="text-4xl font-black">15+</p>
                            <p class="mt-2 text-sm font-bold uppercase tracking-[0.18em] text-slate-500">Years Taste</p>
                        </div>
                        <div class="rounded-3xl border border-orange-100 bg-white p-6 shadow-lg shadow-orange-900/5">
                            <p class="text-4xl font-black">150+</p>
                            <p class="mt-2 text-sm font-bold uppercase tracking-[0.18em] text-slate-500">Plates Served</p>
                        </div>
                    </div>

                    <div class="mt-8">
                        <a href="{{ route('about') }}" class="gradient-button inline-flex items-center justify-center rounded-full px-7 py-4 text-sm font-black uppercase tracking-[0.18em] text-[#24170f] transition hover:-translate-y-0.5">
                            Tentang Kami
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <section class="espresso-section py-24">
            <div class="mx-auto max-w-7xl px-6 lg:px-8">
                <div class="reveal mb-12 flex flex-col justify-between gap-6 md:flex-row md:items-end">
                    <div>
                        <p class="text-sm font-black uppercase tracking-[0.28em] text-[#e5a024]">Popular Dishes</p>
                        <h2 class="mt-4 text-4xl font-black text-white sm:text-5xl">Menu yang sering dipesan.</h2>
                    </div>
                    <a href="{{ route('menu.index') }}" class="inline-flex items-center justify-center rounded-full border border-white/25 px-6 py-3 text-sm font-black uppercase tracking-[0.18em] text-white transition hover:border-[#e5a024] hover:text-[#f4c46b]">
                        Lihat Semua
                    </a>
                </div>

                <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
                    @forelse($featuredMenus as $menu)
                        <article class="reveal magnetic-card glow-card group overflow-hidden rounded-3xl border border-orange-200/15 bg-[#2a1c13]">
                            <div class="relative h-72 overflow-hidden">
                                <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}"
                                     alt="{{ $menu->name }}"
                                     class="h-full w-full object-cover transition duration-700 group-hover:scale-110"
                                     onerror="this.onerror=null; this.src='https://placehold.co/600x420/182433/ffffff?text=Technoir+Bistro';">
                                <div class="absolute inset-0 bg-gradient-to-t from-[#1b120c] via-transparent to-transparent"></div>
                                <span class="absolute left-5 top-5 rounded-full bg-[#e5a024] px-3 py-1 text-xs font-black uppercase tracking-[0.16em] text-[#111827]">
                                    {{ $menu->category->name ?? 'Menu' }}
                                </span>
                            </div>
                            <div class="p-6">
                                <div class="flex items-start justify-between gap-4">
                                    <h3 class="text-xl font-black text-white">{{ $menu->name }}</h3>
                                    <p class="shrink-0 text-lg font-black text-[#f4c46b]">Rp {{ number_format($menu->price, 0, ',', '.') }}</p>
                                </div>
                                <p class="mt-4 min-h-[56px] text-sm leading-7 text-slate-400">{{ $menu->description }}</p>
                                <a href="{{ route('menu.index') }}" class="mt-6 inline-flex text-sm font-black uppercase tracking-[0.18em] text-[#f4c46b] transition hover:text-white">
                                    Detail Menu
                                </a>
                            </div>
                        </article>
                    @empty
                        <div class="reveal rounded-3xl border border-orange-200/15 bg-[#2a1c13] p-10 text-center text-slate-300 md:col-span-3">
                            Menu sedang disiapkan. Silakan cek kembali sebentar lagi.
                        </div>
                    @endforelse
                </div>
            </div>
        </section>

        <section class="warm-section relative py-24 text-[#24170f]">
            <div class="mx-auto max-w-7xl px-6 lg:px-8">
                <div class="grid grid-cols-1 gap-8 lg:grid-cols-[0.85fr_1.15fr]">
                    <div class="reveal">
                        <p class="text-sm font-black uppercase tracking-[0.28em] text-[#b87912]">Services</p>
                        <h2 class="gradient-heading mt-4 text-4xl font-black sm:text-5xl">Datang, duduk, semuanya terasa ringan.</h2>
                    </div>

                    <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div class="reveal glow-card rounded-3xl border border-orange-100 bg-white p-6 shadow-lg shadow-orange-900/5">
                            <p class="text-3xl font-black text-[#e5a024]">01</p>
                            <h3 class="mt-6 text-lg font-black">Online Booking</h3>
                            <p class="mt-3 text-sm leading-7 text-[#60422b]">Reservasi meja langsung tanpa perlu telepon.</p>
                        </div>
                        <div class="reveal glow-card rounded-3xl border border-orange-100 bg-white p-6 shadow-lg shadow-orange-900/5">
                            <p class="text-3xl font-black text-[#c98316]">02</p>
                            <h3 class="mt-6 text-lg font-black">Pre-order Menu</h3>
                            <p class="mt-3 text-sm leading-7 text-[#60422b]">Pilih hidangan lebih awal untuk kedatangan yang lebih lancar.</p>
                        </div>
                        <div class="reveal glow-card rounded-3xl border border-orange-100 bg-white p-6 shadow-lg shadow-orange-900/5">
                            <p class="text-3xl font-black text-[#8f5d13]">03</p>
                            <h3 class="mt-6 text-lg font-black">Cozy Seating</h3>
                            <p class="mt-3 text-sm leading-7 text-[#60422b]">Indoor, rooftop, dan meja kapasitas kecil sampai grup.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="espresso-section py-24">
            <div class="mx-auto max-w-7xl px-6 lg:px-8">
                <div class="reveal mx-auto max-w-3xl text-center">
                    <p class="text-sm font-black uppercase tracking-[0.28em] text-[#e5a024]">Testimoni</p>
                    <h2 class="mt-4 text-4xl font-black text-white sm:text-5xl">Apa kata mereka?</h2>
                    <p class="mt-5 leading-8 text-slate-300">Cerita singkat dari tamu yang datang untuk makan, reservasi, dan merayakan momen kecil di Technoir Bistro.</p>
                </div>

                <div class="reveal mx-auto mt-12 max-w-5xl overflow-hidden">
                    <div class="testimonial-track flex w-[300%]">
                        <article class="w-1/3 px-3">
                            <div class="glow-card h-full rounded-3xl border border-orange-200/15 bg-[#2a1c13] p-7 shadow-2xl shadow-black/20">
                                <div class="flex items-center gap-4">
                                    <img src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=160&q=80" alt="Nadia Putri" class="h-14 w-14 rounded-full object-cover">
                                    <div>
                                        <h3 class="font-black text-white">Nadia Putri</h3>
                                        <p class="text-sm text-slate-400">Dinner bersama keluarga</p>
                                    </div>
                                </div>
                                <p class="mt-5 text-[#f4c46b]">&#9733;&#9733;&#9733;&#9733;&#9733;</p>
                                <p class="mt-4 leading-8 text-slate-300">Reservasinya gampang, suasananya hangat, dan makanan datang tepat waktu. Cocok buat makan malam tanpa ribet.</p>
                            </div>
                        </article>

                        <article class="w-1/3 px-3">
                            <div class="glow-card h-full rounded-3xl border border-orange-200/15 bg-[#2a1c13] p-7 shadow-2xl shadow-black/20">
                                <div class="flex items-center gap-4">
                                    <img src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=160&q=80" alt="Raka Pratama" class="h-14 w-14 rounded-full object-cover">
                                    <div>
                                        <h3 class="font-black text-white">Raka Pratama</h3>
                                        <p class="text-sm text-slate-400">Reservasi rooftop</p>
                                    </div>
                                </div>
                                <p class="mt-5 text-[#f4c46b]">&#9733;&#9733;&#9733;&#9733;&#9733;</p>
                                <p class="mt-4 leading-8 text-slate-300">Rooftop-nya nyaman dan tidak terlalu ramai. Detail pembayaran dan menu juga jelas dari awal.</p>
                            </div>
                        </article>

                        <article class="w-1/3 px-3">
                            <div class="glow-card h-full rounded-3xl border border-orange-200/15 bg-[#2a1c13] p-7 shadow-2xl shadow-black/20">
                                <div class="flex items-center gap-4">
                                    <img src="https://images.unsplash.com/photo-1534751516642-a1af1ef26a56?auto=format&fit=crop&w=160&q=80" alt="Maya Sari" class="h-14 w-14 rounded-full object-cover">
                                    <div>
                                        <h3 class="font-black text-white">Maya Sari</h3>
                                        <p class="text-sm text-slate-400">Pre-order menu</p>
                                    </div>
                                </div>
                                <p class="mt-5 text-[#f4c46b]">&#9733;&#9733;&#9733;&#9733;&#9733;</p>
                                <p class="mt-4 leading-8 text-slate-300">Pre-order bikin pengalaman lebih cepat. Datang, duduk, lalu makanan sudah siap tidak lama setelahnya.</p>
                            </div>
                        </article>
                    </div>
                </div>
            </div>
        </section>

        <section class="relative bg-cover bg-center py-28" style="background-image: linear-gradient(rgba(27, 18, 12, 0.84), rgba(27, 18, 12, 0.78)), url('https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=1600&q=85');">
            <div class="mx-auto max-w-4xl px-6 text-center lg:px-8">
                <div class="reveal">
                    <p class="text-sm font-black uppercase tracking-[0.28em] text-[#f4c46b]">Reservation</p>
                    <h2 class="mt-5 text-4xl font-black text-white sm:text-6xl">Siapkan meja terbaik untuk malam ini.</h2>
                    <p class="mx-auto mt-6 max-w-2xl leading-8 text-slate-200">
                        Pilih waktu, tentukan jumlah tamu, dan lanjutkan pembayaran dengan alur yang sudah disiapkan.
                    </p>
                    <div class="mt-9 flex flex-col justify-center gap-3 sm:flex-row">
                        <a href="{{ route('reservations.create') }}" class="gradient-button inline-flex items-center justify-center rounded-full px-8 py-4 text-sm font-black uppercase tracking-[0.18em] text-[#24170f] transition hover:-translate-y-0.5">
                            Reservasi Sekarang
                        </a>
                        <a href="{{ route('contact') }}" class="inline-flex items-center justify-center rounded-full border border-white/35 px-8 py-4 text-sm font-black uppercase tracking-[0.18em] text-white transition hover:-translate-y-0.5 hover:border-[#e5a024] hover:text-[#f4c46b]">
                            Contact Us
                        </a>
                    </div>
                </div>
            </div>
        </section>

        <footer class="border-t border-orange-200/10 bg-[#120c08] pt-16">
            <div class="mx-auto grid max-w-7xl grid-cols-1 gap-10 px-6 pb-12 md:grid-cols-4 lg:px-8">
                <div class="md:col-span-2">
                    <h3 class="text-2xl font-black uppercase tracking-[0.18em] text-white">Technoir <span class="text-[#e5a024]">Bistro</span></h3>
                    <p class="mt-4 max-w-md leading-8 text-slate-400">Bistro modern untuk reservasi cepat, suasana noir yang nyaman, dan pilihan menu yang siap menemani malam Anda.</p>
                    <div class="mt-6 flex gap-3">
                        <a href="#" class="flex h-10 w-10 items-center justify-center rounded-full border border-white/10 text-slate-300 transition hover:border-[#e5a024] hover:bg-[#e5a024] hover:text-[#111827]" aria-label="Facebook">
                            <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24"><path d="M14 8.5V6.8c0-.8.5-1 1-1h2V2.3c-.4-.1-1.7-.3-3.2-.3-3.2 0-5.3 1.9-5.3 5.5v1H5v4h3.5V22H13v-9.5h3.1l.5-4H13z"/></svg>
                        </a>
                        <a href="#" class="flex h-10 w-10 items-center justify-center rounded-full border border-white/10 text-slate-300 transition hover:border-[#e5a024] hover:bg-[#e5a024] hover:text-[#111827]" aria-label="Instagram">
                            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><rect width="16" height="16" x="4" y="4" rx="4" stroke-width="2"/><circle cx="12" cy="12" r="3.3" stroke-width="2"/><path stroke-linecap="round" stroke-width="2" d="M16.8 7.2h.01"/></svg>
                        </a>
                        <a href="#" class="flex h-10 w-10 items-center justify-center rounded-full border border-white/10 text-slate-300 transition hover:border-[#e5a024] hover:bg-[#e5a024] hover:text-[#111827]" aria-label="X">
                            <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24"><path d="M18.2 2h3.3l-7.2 8.2L22.7 22h-6.6l-5.2-6.8L5 22H1.7l7.7-8.8L1.3 2h6.8l4.7 6.2zm-1.1 18h1.8L7.1 3.9H5.2z"/></svg>
                        </a>
                    </div>
                </div>

                <div>
                    <h4 class="font-black uppercase tracking-[0.18em] text-white">Menu</h4>
                    <div class="mt-5 space-y-3 text-sm text-slate-400">
                        <a href="{{ route('home') }}" class="block transition hover:text-[#f4c46b]">Home</a>
                        <a href="{{ route('about') }}" class="block transition hover:text-[#f4c46b]">About</a>
                        <a href="{{ route('menu.index') }}" class="block transition hover:text-[#f4c46b]">Menu</a>
                        <a href="{{ route('contact') }}" class="block transition hover:text-[#f4c46b]">Contact</a>
                    </div>
                </div>

                <div>
                    <h4 class="font-black uppercase tracking-[0.18em] text-white">Kontak</h4>
                    <div class="mt-5 space-y-3 text-sm leading-7 text-slate-400">
                        <p>Jl. Braga No. 100, Bandung</p>
                        <p>hello@technoir.com</p>
                        <p>+62 812 3456 7890</p>
                    </div>
                </div>
            </div>

            <div class="border-t border-white/10 py-6">
                <div class="mx-auto flex max-w-7xl flex-col items-center justify-between gap-3 px-6 text-center md:flex-row lg:px-8">
                    <p class="text-xs font-bold uppercase tracking-[0.22em] text-slate-500">&copy; 2026 Technoir Bistro. All rights reserved.</p>
                    <div class="flex gap-5 text-xs font-bold uppercase tracking-[0.18em] text-slate-500">
                        <a href="#" class="transition hover:text-[#f4c46b]">Privacy</a>
                        <a href="#" class="transition hover:text-[#f4c46b]">Terms</a>
                    </div>
                </div>
            </div>
        </footer>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const revealItems = document.querySelectorAll('.reveal');

            if ('IntersectionObserver' in window) {
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach((entry) => {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('is-visible');
                            observer.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.14 });

                revealItems.forEach((item, index) => {
                    item.style.transitionDelay = `${Math.min(index * 60, 360)}ms`;
                    observer.observe(item);
                });
            } else {
                revealItems.forEach((item) => item.classList.add('is-visible'));
            }
        });
    </script>
</x-app-layout>
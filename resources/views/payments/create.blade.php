<x-app-layout>
    <style>
        .payment-reveal {
            opacity: 0;
            transform: translateY(16px);
            transition: opacity 560ms ease, transform 560ms ease;
        }

        .payment-reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .payment-field {
            width: 100%;
            border-radius: 18px;
            border: 1px solid #ead8c0;
            background: #fffdf9;
            color: #1f1712;
            transition: border-color 180ms ease, box-shadow 180ms ease, background-color 180ms ease;
        }

        .payment-field:focus {
            border-color: #ea8e16;
            box-shadow: 0 0 0 4px rgba(234, 142, 22, .12);
            outline: none;
        }

        .soft-card {
            transition: transform 220ms ease, border-color 220ms ease, box-shadow 220ms ease;
        }

        .soft-card:hover {
            transform: translateY(-3px);
            border-color: rgba(234, 142, 22, .36);
            box-shadow: 0 18px 45px rgba(117, 74, 25, .10);
        }

        .pay-pulse {
            animation: payPulse 3.2s ease-in-out infinite;
        }

        @keyframes payPulse {
            0%, 100% {
                box-shadow: 0 0 0 rgba(234, 142, 22, 0);
            }
            50% {
                box-shadow: 0 0 34px rgba(234, 142, 22, .18);
            }
        }

        @media (prefers-reduced-motion: reduce) {
            .payment-reveal,
            .soft-card,
            .pay-pulse {
                animation: none;
                transition: none;
                transform: none;
            }
        }
    </style>

    <div class="min-h-screen bg-[#fbf7f1] text-[#1f1712]">
        <main class="mx-auto max-w-6xl px-6 py-10 lg:px-8">
            <section class="payment-reveal overflow-hidden rounded-[30px] border border-[#f0dfca] bg-white shadow-sm">
                <div class="grid grid-cols-1 gap-6 p-7 md:p-9 lg:grid-cols-[1fr_300px] lg:items-center">
                    <div>
                        <div class="inline-flex rounded-full border border-[#f1d8b8] bg-[#fff8ed] px-3 py-1.5 text-xs font-black uppercase tracking-[0.18em] text-[#b76b0c]">
                            Secure Payment
                        </div>
                        <h1 class="mt-5 text-3xl font-black tracking-tight md:text-5xl">Pembayaran Reservasi</h1>
                        <p class="mt-4 max-w-2xl text-sm leading-7 text-[#6b5b4c] md:text-base">
                            Periksa detail reservasi dan lanjutkan pembayaran melalui Xendit.
                        </p>
                    </div>

                    <div class="rounded-3xl bg-gradient-to-br from-[#fff8ed] to-[#ffe8bf] p-5">
                        <p class="text-xs font-black uppercase tracking-[0.18em] text-[#b76b0c]">Total Menu</p>
                        <p class="mt-3 text-3xl font-black">
                            Rp {{ number_format($reservation->menus->count() > 0 ? $menuTotal : old('amount', 0), 0, ',', '.') }}
                        </p>
                        <p class="mt-2 text-sm leading-6 text-[#6b5b4c]">Pembayaran diproses di halaman aman Xendit.</p>
                    </div>
                </div>
            </section>

            @if (session('error'))
                <div class="payment-reveal mt-6 rounded-3xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-semibold text-red-700">
                    {{ session('error') }}
                </div>
            @endif

            @if (app()->environment('local') && blank(config('services.xendit.secret_key')))
                <div class="payment-reveal mt-6 rounded-3xl border border-yellow-200 bg-yellow-50 px-5 py-4 text-sm font-semibold text-yellow-800">
                    XENDIT_SECRET_KEY belum diisi di file .env. Isi secret key Xendit Sandbox agar tombol bayar bisa membuat invoice.
                </div>
            @endif

            @if ($errors->any())
                <div class="payment-reveal mt-6 rounded-3xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
                    <p class="font-black">Pembayaran belum bisa diproses:</p>
                    <ul class="mt-2 list-disc pl-5">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <section class="mt-7 grid grid-cols-1 gap-6 lg:grid-cols-[1fr_420px]">
                <div class="space-y-6">
                    <article class="payment-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                        <div class="border-b border-[#f3e5d3] pb-5">
                            <p class="text-xs font-black uppercase tracking-[0.18em] text-[#b76b0c]">Detail</p>
                            <h2 class="mt-2 text-2xl font-black">Reservasi</h2>
                        </div>

                        <div class="mt-5 grid grid-cols-1 gap-4 sm:grid-cols-2">
                            @foreach([
                                ['label' => 'Nama', 'value' => $reservation->user->username ?? Auth::user()->username ?? 'Tidak diketahui'],
                                ['label' => 'Tanggal', 'value' => \Carbon\Carbon::parse($reservation->reservation_date)->format('d F Y, H:i')],
                                ['label' => 'Tamu', 'value' => $reservation->guest_count . ' Orang'],
                                ['label' => 'Meja', 'value' => $reservation->table->table_number ?? 'Any'],
                            ] as $item)
                                <div class="rounded-3xl border border-[#f0dfca] bg-[#fffdf9] p-4">
                                    <p class="text-xs font-black uppercase tracking-[0.14em] text-[#a89583]">{{ $item['label'] }}</p>
                                    <p class="mt-2 font-black text-[#1f1712]">{{ $item['value'] }}</p>
                                </div>
                            @endforeach
                        </div>
                    </article>

                    <article class="payment-reveal rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                        <div class="flex items-center justify-between gap-4 border-b border-[#f3e5d3] pb-5">
                            <div>
                                <p class="text-xs font-black uppercase tracking-[0.18em] text-[#b76b0c]">Pesanan</p>
                                <h2 class="mt-2 text-2xl font-black">Menu yang Dipesan</h2>
                            </div>
                            <span class="rounded-full bg-[#fff3df] px-3 py-1 text-xs font-black uppercase tracking-[0.12em] text-[#b76b0c]">
                                {{ $reservation->menus->count() }} Item
                            </span>
                        </div>

                        @if($reservation->menus->count() > 0)
                            <div class="mt-5 space-y-3">
                                @foreach($reservation->menus as $menu)
                                    <div class="soft-card rounded-3xl border border-[#f0dfca] bg-[#fffdf9] p-4">
                                        <div class="flex items-center justify-between gap-4">
                                            <div>
                                                <p class="font-black text-[#1f1712]">{{ $menu->name }}</p>
                                                <p class="mt-1 text-sm text-[#6b5b4c]">Jumlah x{{ $menu->pivot->quantity }}</p>
                                            </div>
                                            <p class="shrink-0 font-black text-[#b76b0c]">
                                                Rp {{ number_format($menu->price * $menu->pivot->quantity, 0, ',', '.') }}
                                            </p>
                                        </div>
                                    </div>
                                @endforeach
                            </div>

                            <div class="mt-5 flex items-center justify-between rounded-3xl bg-[#fff8ed] px-5 py-4">
                                <span class="font-black">Total Menu</span>
                                <span class="text-2xl font-black text-[#b76b0c]">Rp {{ number_format($menuTotal, 0, ',', '.') }}</span>
                            </div>
                        @else
                            <div class="mt-5 rounded-3xl border border-dashed border-[#e8d5bd] bg-[#fffdf9] p-8 text-center text-sm text-[#6b5b4c]">
                                Tidak ada menu pre-order. Masukkan nominal pembayaran secara manual.
                            </div>
                        @endif
                    </article>
                </div>

                <aside class="payment-reveal lg:sticky lg:top-24 lg:self-start">
                    <form action="{{ route('payments.store') }}" method="POST" id="paymentForm" class="pay-pulse rounded-[28px] border border-[#f0dfca] bg-white p-6 shadow-sm">
                        @csrf
                        <input type="hidden" name="reservation_id" value="{{ $reservation->id }}">

                        <div class="border-b border-[#f3e5d3] pb-5">
                            <p class="text-xs font-black uppercase tracking-[0.18em] text-[#b76b0c]">Xendit</p>
                            <h2 class="mt-2 text-2xl font-black">Detail Pembayaran</h2>
                            <p class="mt-2 text-sm leading-6 text-[#6b5b4c]">Anda akan diarahkan ke halaman invoice Xendit setelah menekan tombol bayar.</p>
                        </div>

                        @if($reservation->menus->count() > 0)
                            <div class="mt-5 rounded-3xl bg-gradient-to-br from-[#fff8ed] to-[#ffe8bf] p-5">
                                <p class="text-xs font-black uppercase tracking-[0.16em] text-[#b76b0c]">Total Pembayaran</p>
                                <p class="mt-3 text-4xl font-black text-[#1f1712]">Rp {{ number_format($menuTotal, 0, ',', '.') }}</p>
                                <p class="mt-2 text-sm text-[#6b5b4c]">Total dari menu yang dipesan.</p>
                            </div>
                            <input type="hidden" name="amount" id="amount" value="{{ $menuTotal }}">
                            <x-input-error :messages="$errors->get('amount')" class="mt-2" />
                        @else
                            <div class="mt-5">
                                <x-input-label for="amount" :value="__('Jumlah Transfer (Rp)')" class="text-[#1f1712]" />
                                <input id="amount" class="payment-field mt-2 px-4 py-3" type="number" name="amount" value="{{ old('amount') }}" required placeholder="Contoh: 50000" min="1000" />
                                <p class="mt-2 text-xs text-[#8c7b68]">Minimum pembayaran adalah Rp 1.000.</p>
                                <x-input-error :messages="$errors->get('amount')" class="mt-2" />
                            </div>
                        @endif

                        <div class="mt-6 rounded-3xl border border-[#f0dfca] bg-[#fffdf9] p-4">
                            <div class="flex gap-3">
                                <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl bg-[#fff3df] text-[#b76b0c]">
                                    <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.031 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                    </svg>
                                </span>
                                <div>
                                    <p class="font-black text-[#1f1712]">Bayar via Xendit</p>
                                    <p class="mt-1 text-sm leading-6 text-[#6b5b4c]">Pembayaran aman melalui invoice Xendit Sandbox/Live sesuai konfigurasi.</p>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="mt-6 inline-flex w-full items-center justify-center rounded-full bg-[#1f1712] px-7 py-3 text-sm font-black uppercase tracking-[0.12em] text-white shadow-sm transition hover:-translate-y-0.5 hover:bg-[#ea8e16]">
                            Bayar dengan Xendit
                            <svg class="ml-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                            </svg>
                        </button>
                    </form>
                </aside>
            </section>
        </main>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.payment-reveal').forEach((item, index) => {
                item.style.transitionDelay = `${Math.min(index * 55, 300)}ms`;
                requestAnimationFrame(() => item.classList.add('is-visible'));
            });
        });
    </script>
</x-app-layout>
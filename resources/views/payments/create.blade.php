<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Pembayaran Reservasi') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-4xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                        
                        <!-- Kolom Kiri: Detail -->
                        <div>
                            <h3 class="text-lg font-bold mb-4 border-b pb-2">Detail Reservasi</h3>
                            <div class="space-y-3 text-sm">
                                <p><span class="font-semibold">Nama:</span> 
                                    {{ $reservation->user->username ?? Auth::user()->username ?? 'Tidak diketahui' }}
                                </p>
                                <p><span class="font-semibold">Tanggal:</span> {{ \Carbon\Carbon::parse($reservation->reservation_date)->format('d F Y, H:i') }}</p>
                                <p><span class="font-semibold">Tamu:</span> {{ $reservation->guest_count }} Orang</p>
                                <p><span class="font-semibold">Meja:</span> {{ $reservation->table->name ?? 'Any' }}</p>
                            </div>

                            @if($reservation->menus->count() > 0)
                                <div class="mt-6">
                                    <h4 class="font-semibold text-sm mb-2 border-b pb-1">Menu yang Dipesan:</h4>
                                    <div class="space-y-2 text-xs">
                                        @foreach($reservation->menus as $menu)
                                            <div class="flex justify-between items-center bg-gray-50 dark:bg-gray-700/50 p-2 rounded">
                                                <span>{{ $menu->name }} (x{{ $menu->pivot->quantity }})</span>
                                                <span class="font-semibold">Rp {{ number_format($menu->price * $menu->pivot->quantity, 0, ',', '.') }}</span>
                                            </div>
                                        @endforeach
                                        <div class="flex justify-between items-center font-bold text-base pt-2 border-t border-gray-300 dark:border-gray-600">
                                            <span>Total Menu:</span>
                                            <span class="text-indigo-600 dark:text-indigo-400">Rp {{ number_format($menuTotal, 0, ',', '.') }}</span>
                                        </div>
                                    </div>
                                </div>
                            @endif

                            <div class="mt-8 bg-indigo-50 dark:bg-indigo-900/30 p-4 rounded-lg border border-indigo-100 dark:border-indigo-800">
                                <h4 class="font-bold text-indigo-700 dark:text-indigo-300 mb-2">Bayar via Xendit</h4>
                                <p class="text-sm mb-2">Klik tombol bayar untuk dialihkan ke halaman pembayaran aman Xendit.</p>
                            </div>
                        </div>

                        <!-- Kolom Kanan: Form Pembayaran -->
                        <div>
                            <h3 class="text-lg font-bold mb-4 border-b pb-2">Detail Pembayaran</h3>
                            
                            <form action="{{ route('payments.store') }}" method="POST" id="paymentForm">
                                @csrf
                                <input type="hidden" name="reservation_id" value="{{ $reservation->id }}">

                                @if($reservation->menus->count() > 0)
                                    <!-- Jika ada menu, tampilkan total dan sembunyikan input manual -->
                                    <div class="mb-4">
                                        <x-input-label for="amount" :value="__('Total Pembayaran (Rp)')" />
                                        <div class="mt-1 p-3 bg-gray-50 dark:bg-gray-700 rounded-md border border-gray-300 dark:border-gray-600">
                                            <p class="text-2xl font-bold text-indigo-600 dark:text-indigo-400">
                                                Rp {{ number_format($menuTotal, 0, ',', '.') }}
                                            </p>
                                            <p class="text-xs text-gray-500 mt-1">Total dari menu yang dipesan</p>
                                        </div>
                                        <input type="hidden" name="amount" id="amount" value="{{ $menuTotal }}">
                                    </div>
                                @else
                                    <!-- Jika tidak ada menu, tampilkan input manual -->
                                    <div class="mb-4">
                                        <x-input-label for="amount" :value="__('Jumlah Transfer (Rp)')" />
                                        <x-text-input id="amount" class="block mt-1 w-full" type="number" name="amount" required placeholder="Contoh: 50000" min="50000" />
                                        <p class="text-xs text-gray-500 mt-1">Minimum DP yang harus dibayar adalah Rp 50.000</p>
                                        <x-input-error :messages="$errors->get('amount')" class="mt-2" />
                                    </div>
                                @endif

                                <div class="flex items-center justify-end">
                                    <x-primary-button class="w-full justify-center py-3">
                                        {{ __('Bayar dengan Xendit') }}
                                    </x-primary-button>
                                </div>
                            </form>
                        </div>

                    </div>

                </div>
            </div>
        </div>
    </div>
</x-app-layout>
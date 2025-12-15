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
                                <p><span class="font-semibold">Nama:</span> {{ Auth::user()->name }}</p>
                                <p><span class="font-semibold">Tanggal:</span> {{ \Carbon\Carbon::parse($reservation->reservation_date)->format('d F Y, H:i') }}</p>
                                <p><span class="font-semibold">Tamu:</span> {{ $reservation->guest_count }} Orang</p>
                                <p><span class="font-semibold">Meja:</span> {{ $reservation->table->name ?? 'Any' }}</p>
                            </div>

                            <div class="mt-8 bg-indigo-50 dark:bg-indigo-900/30 p-4 rounded-lg border border-indigo-100 dark:border-indigo-800">
                                <h4 class="font-bold text-indigo-700 dark:text-indigo-300 mb-2">Instruksi Transfer</h4>
                                <p class="text-sm mb-2">Silakan transfer DP minimal <strong>Rp 50.000</strong> ke:</p>
                                
                                <div class="bg-white dark:bg-gray-700 p-3 rounded border border-gray-200 dark:border-gray-600 my-3">
                                    <p class="font-bold text-lg">BCA: 123-456-7890</p>
                                    <p class="text-sm text-gray-500 dark:text-gray-400">a.n. Technoir Bistro</p>
                                </div>
                            </div>
                        </div>

                        <!-- Kolom Kanan: Form Upload -->
                        <div>
                            <h3 class="text-lg font-bold mb-4 border-b pb-2">Upload Bukti Transfer</h3>
                            
                            <form action="{{ route('payments.store') }}" method="POST" enctype="multipart/form-data">
                                @csrf
                                <input type="hidden" name="reservation_id" value="{{ $reservation->id }}">

                                <!-- Input Nominal -->
                                <div class="mb-4">
                                    <x-input-label for="amount" :value="__('Jumlah Transfer (Rp)')" />
                                    <x-text-input id="amount" class="block mt-1 w-full" type="number" name="amount" required placeholder="Contoh: 50000" />
                                    <x-input-error :messages="$errors->get('amount')" class="mt-2" />
                                </div>

                                <!-- Input File -->
                                <div class="mb-6">
                                    <x-input-label for="proof_of_payment" :value="__('Bukti Foto / Screenshot')" />
                                    <input type="file" id="proof_of_payment" name="proof_of_payment" class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 mt-1" required accept="image/*">
                                    <p class="mt-1 text-xs text-gray-500">JPG, PNG. Max 2MB.</p>
                                    <x-input-error :messages="$errors->get('proof_of_payment')" class="mt-2" />
                                </div>

                                <div class="flex items-center justify-end">
                                    <x-primary-button class="w-full justify-center py-3">
                                        {{ __('Kirim Bukti Pembayaran') }}
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
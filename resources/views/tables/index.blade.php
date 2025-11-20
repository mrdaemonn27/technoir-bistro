<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Denah Meja Restoran') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            {{-- Legend / Keterangan Warna --}}
            <div class="mb-6 flex flex-wrap gap-4 justify-center text-sm text-gray-600 dark:text-gray-400">
                <div class="flex items-center"><span class="w-3 h-3 rounded-full bg-green-500 mr-2"></span> Available</div>
                <div class="flex items-center"><span class="w-3 h-3 rounded-full bg-red-500 mr-2"></span> Occupied</div>
                <div class="flex items-center"><span class="w-3 h-3 rounded-full bg-yellow-500 mr-2"></span> Reserved</div>
                <div class="flex items-center"><span class="w-3 h-3 rounded-full bg-blue-500 mr-2"></span> Cleaning</div>
            </div>

            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg p-6">
                
                {{-- Grid Layout Meja --}}
                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    @forelse ($tables as $table)
                        @php
                            // Logika Warna Berdasarkan Status
                            $statusColor = match($table->status) {
                                'available' => 'border-green-500 bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-300',
                                'occupied' => 'border-red-500 bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300',
                                'reserved' => 'border-yellow-500 bg-yellow-50 dark:bg-yellow-900/20 text-yellow-700 dark:text-yellow-300',
                                'cleaning' => 'border-blue-500 bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300',
                                default => 'border-gray-200',
                            };
                        @endphp

                        <div class="relative border-2 {{ $statusColor }} rounded-xl p-6 flex flex-col items-center justify-center transition hover:scale-105 shadow-sm cursor-pointer">
                            
                            {{-- Ikon Meja Sederhana --}}
                            <div class="mb-2">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 opacity-80" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                                </svg>
                            </div>

                            <h3 class="text-2xl font-bold">{{ $table->table_number }}</h3>
                            <p class="text-xs uppercase font-semibold tracking-wider mt-1">{{ $table->status }}</p>
                            
                            <div class="mt-4 text-sm opacity-75 flex items-center gap-2">
                                <span>{{ $table->capacity }} Orang</span>
                                <span>•</span>
                                <span>{{ $table->location }}</span>
                            </div>

                            {{-- Tombol Booking (Hanya muncul jika Available) --}}
                            @if($table->status === 'available')
                                <button class="mt-4 px-4 py-1 bg-green-600 hover:bg-green-700 text-white text-xs rounded-full">
                                    Pesan Sekarang
                                </button>
                            @endif
                        </div>
                    @empty
                        <div class="col-span-full text-center text-gray-500">
                            Belum ada data meja.
                        </div>
                    @endforelse
                </div>

            </div>
        </div>
    </div>
</x-app-layout>
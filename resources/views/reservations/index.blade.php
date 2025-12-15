<x-app-layout>
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <div class="text-center mb-10">
                <span class="text-[#E5A024] font-serif italic text-xl">My History</span>
                <h2 class="text-3xl font-bold text-[#2D2D2D]">Riwayat Reservasi Saya</h2>
            </div>

            {{-- Pesan Sukses / Error --}}
            @if(session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-6 text-center" role="alert">
                    <span class="block sm:inline">{{ session('success') }}</span>
                </div>
            @endif
            @if(session('error'))
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6 text-center" role="alert">
                    <span class="block sm:inline">{{ session('error') }}</span>
                </div>
            @endif

            <div class="grid gap-6">
                @forelse($reservations as $reservation)
                    <div class="bg-white rounded-xl shadow-md overflow-hidden border-l-4 {{ $reservation->status == 'confirmed' ? 'border-green-500' : ($reservation->status == 'cancelled' ? 'border-red-500' : 'border-yellow-500') }}">
                        <div class="p-6">
                            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-4">
                                <div>
                                    <p class="text-sm text-gray-500">ID Reservasi: #{{ $reservation->id }}</p>
                                    <h3 class="text-xl font-bold text-[#2D2D2D] mt-1">
                                        {{ \Carbon\Carbon::parse($reservation->reservation_date)->format('l, d F Y') }}
                                    </h3>
                                    <p class="text-[#E5A024] font-semibold text-lg">
                                        Pukul {{ \Carbon\Carbon::parse($reservation->reservation_date)->format('H:i') }} WIB
                                    </p>
                                </div>
                                <div class="mt-4 md:mt-0 text-right">
                                    <span class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide
                                        {{ $reservation->status == 'confirmed' ? 'bg-green-100 text-green-800' : 
                                           ($reservation->status == 'cancelled' ? 'bg-red-100 text-red-800' : 'bg-yellow-100 text-yellow-800') }}">
                                        {{ $reservation->status }}
                                    </span>
                                    <p class="text-sm text-gray-500 mt-2">Dibuat pada: {{ $reservation->created_at->diffForHumans() }}</p>
                                </div>
                            </div>

                            <hr class="border-gray-100 my-4">

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {{-- Info Meja --}}
                                <div>
                                    <h4 class="font-bold text-gray-700 mb-2">Detail Meja</h4>
                                    <div class="flex items-center text-gray-600 bg-gray-50 p-3 rounded-lg">
                                        <div class="mr-3 bg-white p-2 rounded-full shadow-sm">
                                            <svg class="w-5 h-5 text-[#E5A024]" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                                        </div>
                                        <div>
                                            <p class="font-semibold">Meja {{ $reservation->table->table_number }} <span class="text-xs text-gray-400">({{ $reservation->table->location }})</span></p>
                                            <p class="text-sm">{{ $reservation->guest_count }} Orang</p>
                                        </div>
                                    </div>
                                    
                                    @if($reservation->notes)
                                        <div class="mt-3 text-sm text-gray-500 bg-yellow-50 p-3 rounded-lg border border-yellow-100">
                                            <span class="font-bold">Catatan:</span> {{ $reservation->notes }}
                                        </div>
                                    @endif
                                </div>

                                {{-- Info Menu Pre-order (FR-06) --}}
                                <div>
                                    <h4 class="font-bold text-gray-700 mb-2">Pesanan Makanan</h4>
                                    @if($reservation->menus->count() > 0)
                                        <div class="bg-gray-50 p-3 rounded-lg space-y-2">
                                            @foreach($reservation->menus as $menu)
                                                <div class="flex justify-between items-center text-sm">
                                                    <div class="flex items-center">
                                                        <span class="bg-[#2D2D2D] text-white text-xs w-5 h-5 flex items-center justify-center rounded-full mr-2">
                                                            {{ $menu->pivot->quantity }}x
                                                        </span>
                                                        <span class="text-gray-700">{{ $menu->name }}</span>
                                                    </div>
                                                    <span class="font-semibold text-gray-900">
                                                        Rp {{ number_format($menu->price * $menu->pivot->quantity, 0, ',', '.') }}
                                                    </span>
                                                </div>
                                            @endforeach
                                            
                                            <div class="border-t border-gray-200 mt-2 pt-2 flex justify-between items-center font-bold text-[#E5A024]">
                                                <span>Total Estimasi</span>
                                                @php
                                                    $total = $reservation->menus->sum(function($menu) {
                                                        return $menu->price * $menu->pivot->quantity;
                                                    });
                                                @endphp
                                                <span>Rp {{ number_format($total, 0, ',', '.') }}</span>
                                            </div>
                                        </div>
                                    @else
                                        <p class="text-sm text-gray-400 italic p-3 bg-gray-50 rounded-lg">Tidak ada makanan yang dipesan sebelumnya.</p>
                                    @endif
                                </div>
                            </div>

                            {{-- ========================================== --}}
                            {{-- INI ADALAH BAGIAN TOMBOL PEMBATALAN (FR-08) --}}
                            {{-- ========================================== --}}
                            @if($reservation->status == 'pending')
                                <div class="mt-6 flex justify-end gap-3 border-t border-gray-100 pt-4">
                                    {{-- Tombol Edit --}}
                                    <a href="{{ route('reservations.edit', $reservation->id) }}" class="px-4 py-2 bg-yellow-50 text-yellow-600 hover:bg-yellow-100 rounded-lg font-bold text-sm transition border border-yellow-200">
                                        Ubah Pesanan
                                    </a>
                                    
                                    {{-- Tombol Batal --}}
                                    <form action="{{ route('reservations.destroy', $reservation->id) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin membatalkan reservasi ini?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="px-4 py-2 bg-red-50 text-red-600 hover:bg-red-100 rounded-lg font-bold text-sm transition border border-red-200">
                                            Batalkan Reservasi
                                        </button>
                                    </form>
                                </div>
                            @elseif($reservation->status == 'cancelled')
                                <div class="mt-4 text-right">
                                    <span class="text-sm text-red-500 italic font-semibold border border-red-200 bg-red-50 px-3 py-1 rounded">Reservasi telah dibatalkan</span>
                                </div>
                            @endif
                            {{-- ========================================== --}}

                        </div>
                    </div>
                @empty
                    <div class="text-center py-16 bg-white rounded-xl shadow-sm">
                        <h3 class="text-lg font-bold text-gray-900">Belum Ada Reservasi</h3>
                        <p class="text-gray-500 mb-6">Anda belum pernah melakukan reservasi di Technoir Bistro.</p>
                        <a href="{{ route('reservations.create') }}" class="inline-block bg-[#E5A024] hover:bg-orange-600 text-white font-bold py-3 px-8 rounded-full transition shadow-lg">
                            Buat Reservasi Sekarang
                        </a>
                    </div>
                @endforelse
            </div>
        </div>
    </div>
</x-app-layout>
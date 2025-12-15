<x-app-layout>
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <div class="text-center mb-10">
                <span class="text-[#E5A024] font-serif italic text-xl">Change Plans</span>
                <h2 class="text-3xl font-bold text-[#2D2D2D]">Ubah Reservasi</h2>
            </div>

            <form action="{{ route('reservations.update', $reservation->id) }}" method="POST">
                @csrf
                @method('PUT') {{-- Method Spoofing untuk Update --}}

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    
                    {{-- Edit Data Diri & Meja --}}
                    <div class="lg:col-span-1">
                        <div class="bg-white p-6 rounded-xl shadow-lg border-t-4 border-[#E5A024] sticky top-24">
                            <h3 class="text-xl font-bold text-[#2D2D2D] mb-6 border-b pb-2">Detail Reservasi</h3>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Waktu Kedatangan</label>
                                {{-- Format tanggal untuk input datetime-local: Y-m-d\TH:i --}}
                                <input type="datetime-local" name="reservation_date" 
                                       value="{{ \Carbon\Carbon::parse($reservation->reservation_date)->format('Y-m-d\TH:i') }}"
                                       class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" required>
                            </div>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Pilih Meja</label>
                                <select name="table_id" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" required>
                                    @foreach($tables as $table)
                                        <option value="{{ $table->id }}" {{ $reservation->table_id == $table->id ? 'selected' : '' }}>
                                            Meja {{ $table->table_number }} ({{ $table->capacity }} Org) - {{ $table->location }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Jumlah Tamu</label>
                                <input type="number" name="guest_count" min="1" value="{{ $reservation->guest_count }}" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" required>
                            </div>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Catatan</label>
                                <textarea name="notes" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" rows="3">{{ $reservation->notes }}</textarea>
                            </div>
                        </div>
                    </div>

                    {{-- Edit Menu Makanan --}}
                    <div class="lg:col-span-2">
                        <div class="bg-white p-6 rounded-xl shadow-lg">
                            <div class="flex justify-between items-center mb-6 border-b pb-2">
                                <h3 class="text-xl font-bold text-[#2D2D2D]">Edit Pesanan Makanan</h3>
                                <span class="text-xs text-white bg-[#E5A024] px-2 py-1 rounded font-bold">OPSIONAL</span>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-h-[600px] overflow-y-auto pr-2 custom-scrollbar">
                                @foreach($menus as $menu)
                                    @php
                                        // Cek apakah menu ini sudah ada di reservasi sebelumnya
                                        // Kita cari di koleksi $reservation->menus
                                        $existingItem = $reservation->menus->find($menu->id);
                                        $currentQty = $existingItem ? $existingItem->pivot->quantity : 0;
                                    @endphp

                                    <div class="flex items-center bg-[#FFF8F5] p-3 rounded-lg border border-gray-100 hover:border-[#E5A024] transition">
                                        {{-- Gambar Kecil --}}
                                        <div class="relative w-16 h-16 mr-4 flex-shrink-0">
                                            <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                                 class="w-full h-full object-cover rounded-md"
                                                 onerror="this.src='https://placehold.co/100x100/E5E5E5/555?text=No+Img'">
                                        </div>
                                        
                                        <div class="flex-1 min-w-0">
                                            <h4 class="font-bold text-[#2D2D2D] text-sm truncate">{{ $menu->name }}</h4>
                                            <p class="text-[#E5A024] font-bold text-xs">Rp {{ number_format($menu->price, 0, ',', '.') }}</p>
                                        </div>

                                        {{-- Input Qty (Terisi data lama jika ada) --}}
                                        <div class="w-16 ml-2">
                                            <label class="text-[10px] text-gray-500 block text-center mb-1">Qty</label>
                                            <input type="number" 
                                                   name="menus[{{ $menu->id }}]" 
                                                   min="0" 
                                                   value="{{ $currentQty }}" 
                                                   class="w-full h-8 text-center border-gray-300 rounded focus:ring-[#E5A024] focus:border-[#E5A024] text-sm bg-white"
                                                   onfocus="this.select()">
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>

                        {{-- Tombol Aksi --}}
                        <div class="mt-8 flex justify-end gap-4">
                            <a href="{{ route('reservations.index') }}" class="px-6 py-3 border border-gray-300 text-gray-700 font-bold rounded-full hover:bg-gray-100 transition">
                                Batal
                            </a>
                            <button type="submit" class="bg-[#2D2D2D] hover:bg-[#E5A024] text-white font-bold py-3 px-8 rounded-full shadow-lg transition duration-300">
                                Simpan Perubahan
                            </button>
                        </div>
                    </div>

                </div>
            </form>
        </div>
    </div>
</x-app-layout>
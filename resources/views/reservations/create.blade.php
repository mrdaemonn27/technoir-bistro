<x-app-layout>
    {{-- RestoNest Theme Colors --}}
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            {{-- Header --}}
            <div class="text-center mb-10">
                <span class="text-[#E5A024] font-serif italic text-xl">Book a Table</span>
                <h2 class="text-3xl font-bold text-[#2D2D2D]">Buat Reservasi Baru</h2>
                <p class="text-gray-500 mt-2">Silakan isi detail reservasi dan pilih menu favorit Anda.</p>
            </div>

            <form action="{{ route('reservations.store') }}" method="POST">
                @csrf

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    
                    {{-- BAGIAN KIRI: Form Data Diri & Meja --}}
                    <div class="lg:col-span-1">
                        <div class="bg-white p-6 rounded-xl shadow-lg border-t-4 border-[#E5A024] sticky top-24">
                            <h3 class="text-xl font-bold text-[#2D2D2D] mb-6 border-b pb-2">Detail Reservasi</h3>

                            <!-- Tanggal & Waktu -->
                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Waktu Kedatangan</label>
                                <input type="datetime-local" name="reservation_date" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" required>
                            </div>

                            <!-- Pilih Meja -->
                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Pilih Meja</label>
                                <select name="table_id" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" required>
                                    <option value="" disabled selected>-- Pilih Meja --</option>
                                    @foreach($tables as $table)
                                        <option value="{{ $table->id }}">
                                            Meja {{ $table->table_number }} (Kapasitas: {{ $table->capacity }} Org) - {{ $table->location }}
                                        </option>
                                    @endforeach
                                </select>
                            </div>

                            <!-- Jumlah Tamu -->
                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Jumlah Tamu</label>
                                <input type="number" name="guest_count" min="1" value="2" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" required>
                            </div>

                            <!-- Catatan -->
                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Catatan (Opsional)</label>
                                <textarea name="notes" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" rows="3" placeholder="Alergi, kursi bayi, dekorasi ultah, dll."></textarea>
                            </div>
                        </div>
                    </div>

                    {{-- BAGIAN KANAN: (FR-06) Pilih Menu Makanan --}}
                    <div class="lg:col-span-2">
                        <div class="bg-white p-6 rounded-xl shadow-lg">
                            <div class="flex justify-between items-center mb-6 border-b pb-2">
                                <div>
                                    <h3 class="text-xl font-bold text-[#2D2D2D]">Pesan Makanan (Pre-order)</h3>
                                    <p class="text-xs text-gray-500 mt-1">Makanan akan disiapkan menjelang kedatangan Anda.</p>
                                </div>
                                <span class="text-xs text-white bg-[#E5A024] px-2 py-1 rounded font-bold">OPSIONAL</span>
                            </div>

                            {{-- Grid Daftar Menu --}}
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-h-[600px] overflow-y-auto pr-2 custom-scrollbar">
                                @foreach($menus as $menu)
                                    <div class="flex items-center bg-[#FFF8F5] p-3 rounded-lg border border-gray-100 hover:border-[#E5A024] transition group">
                                        {{-- Gambar Kecil --}}
                                        <div class="relative w-16 h-16 mr-4 flex-shrink-0">
                                            <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                                 class="w-full h-full object-cover rounded-md"
                                                 onerror="this.src='https://placehold.co/100x100/E5E5E5/555?text=No+Img'">
                                        </div>
                                        
                                        <div class="flex-1 min-w-0">
                                            <h4 class="font-bold text-[#2D2D2D] text-sm truncate" title="{{ $menu->name }}">{{ $menu->name }}</h4>
                                            <p class="text-[#E5A024] font-bold text-xs">Rp {{ number_format($menu->price, 0, ',', '.') }}</p>
                                            <p class="text-[10px] text-gray-500 truncate">{{ $menu->category->name }}</p>
                                        </div>

                                        {{-- Input Qty --}}
                                        <div class="w-16 ml-2">
                                            <label class="text-[10px] text-gray-500 block text-center mb-1">Qty</label>
                                            <input type="number" 
                                                   name="menus[{{ $menu->id }}]" 
                                                   min="0" 
                                                   value="0" 
                                                   class="w-full h-8 text-center border-gray-300 rounded focus:ring-[#E5A024] focus:border-[#E5A024] text-sm bg-white"
                                                   onfocus="this.select()">
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                            
                            @if($menus->isEmpty())
                                <div class="text-center py-8 text-gray-500">
                                    <p>Menu belum tersedia saat ini.</p>
                                </div>
                            @endif
                        </div>

                        {{-- Tombol Submit --}}
                        <div class="mt-8 flex justify-end">
                            <button type="submit" class="bg-[#2D2D2D] hover:bg-[#E5A024] text-white font-bold py-3 px-8 rounded-full shadow-lg transition duration-300 flex items-center transform hover:scale-105">
                                <span>Konfirmasi Reservasi</span>
                                <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path></svg>
                            </button>
                        </div>
                    </div>

                </div>
            </form>
        </div>
    </div>
</x-app-layout>
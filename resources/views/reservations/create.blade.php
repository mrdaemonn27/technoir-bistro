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
                                <input type="datetime-local" 
                                       name="reservation_date" 
                                       id="reservation_date"
                                       min="{{ \Carbon\Carbon::now()->addHour()->startOfHour()->format('Y-m-d\TH:i') }}"
                                       step="3600"
                                       class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" 
                                       required>
                                <p class="text-xs text-gray-500 mt-1">Pilih jam genap (contoh: 12:00, 13:00, 14:00)</p>
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

                            @php
                                $favoritesCollection = !empty($favoriteMenuIds ?? []) ? $menus->whereIn('id', $favoriteMenuIds) : collect();
                                $otherMenus = !empty($favoriteMenuIds ?? []) ? $menus->whereNotIn('id', $favoriteMenuIds) : $menus;
                            @endphp

                            {{-- Section: Menu Favorit Anda --}}
                            @auth
                                @if($favoritesCollection->isNotEmpty())
                                    <div class="mb-6">
                                        <div class="border-2 border-dashed border-[#E6B24D]/50 bg-[#E6B24D]/5 rounded-lg p-3 mb-6 flex items-center gap-3">
                                            <svg class="h-5 w-5 text-[#E6B24D]" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd" />
                                            </svg>
                                            <span class="text-sm font-medium text-gray-700">Menu Favorit Anda</span>
                                        </div>

                                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                                            @foreach($favoritesCollection as $menu)
                                                <div class="border border-gray-100 rounded-xl p-4 hover:shadow-md transition-shadow flex gap-4 items-center bg-gray-50/50">
                                                    <div class="w-24 h-24 rounded-lg overflow-hidden flex-shrink-0 bg-gray-200">
                                                        <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                                             class="w-full h-full object-cover"
                                                             alt="{{ $menu->name }}"
                                                             onerror="this.src='https://placehold.co/160x160/E5E5E5/555?text=No+Img'">
                                                    </div>
                                                    <div class="flex-1 min-w-0">
                                                        <div class="flex justify-between items-start">
                                                            <span class="text-xs font-bold text-white px-1.5 py-0.5 rounded-sm mb-1 inline-block bg-[#FF6B6B]">FAVORIT</span>
                                                        </div>
                                                        <h3 class="font-bold text-gray-800 truncate">{{ $menu->name }}</h3>
                                                        <p class="text-xs text-gray-500 mb-2">{{ $menu->category->name ?? '' }}</p>
                                                        <div class="flex justify-between items-end">
                                                            <span class="font-bold text-[#5D3FD3]">Rp {{ number_format($menu->price, 0, ',', '.') }}</span>
                                                            <div class="flex items-center border border-gray-300 rounded-md bg-white">
                                                                <button type="button" class="px-2 py-0.5 text-gray-500 hover:bg-gray-100 rounded-l-md qty-btn" data-type="minus" data-input-id="qty-{{ $menu->id }}">-</button>
                                                                <input id="qty-{{ $menu->id }}" name="menus[{{ $menu->id }}]" type="number" min="0" value="0" class="w-8 text-center text-xs border-none p-0 focus:ring-0">
                                                                <button type="button" class="px-2 py-0.5 text-gray-500 hover:bg-gray-100 rounded-r-md qty-btn" data-type="plus" data-input-id="qty-{{ $menu->id }}">+</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            @endforeach
                                        </div>
                                    </div>
                                @endif
                            @endauth

                            {{-- Section: Menu lain --}}
                            @if($otherMenus->isNotEmpty())
                                <h4 class="font-bold text-gray-800 text-lg mb-4 border-b pb-2">Menu lain</h4>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    @foreach($otherMenus as $menu)
                                        <div class="border border-gray-100 rounded-xl p-4 hover:shadow-md transition-shadow flex gap-4 items-center">
                                            <div class="w-24 h-24 rounded-lg overflow-hidden flex-shrink-0 bg-gray-200">
                                                <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                                     class="w-full h-full object-cover"
                                                     alt="{{ $menu->name }}"
                                                     onerror="this.src='https://placehold.co/160x160/E5E5E5/555?text=No+Img'">
                                            </div>
                                            <div class="flex-1 min-w-0">
                                                <h3 class="font-bold text-gray-800 truncate">{{ $menu->name }}</h3>
                                                <p class="text-xs text-gray-500 mb-2">{{ $menu->category->name ?? '' }}</p>
                                                <div class="flex justify-between items-end">
                                                    <span class="font-bold text-[#5D3FD3]">Rp {{ number_format($menu->price, 0, ',', '.') }}</span>
                                                    <div class="flex items-center border border-gray-300 rounded-md bg-white">
                                                        <button type="button" class="px-2 py-0.5 text-gray-500 hover:bg-gray-100 rounded-l-md qty-btn" data-type="minus" data-input-id="qty-{{ $menu->id }}">-</button>
                                                        <input id="qty-{{ $menu->id }}" name="menus[{{ $menu->id }}]" type="number" min="0" value="0" class="w-8 text-center text-xs border-none p-0 focus:ring-0">
                                                        <button type="button" class="px-2 py-0.5 text-gray-500 hover:bg-gray-100 rounded-r-md qty-btn" data-type="plus" data-input-id="qty-{{ $menu->id }}">+</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            @endif
                            
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

    <script>
        // Membatasi input datetime-local hanya jam genap (menit harus 00)
        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('reservation_date');
            
            if (dateInput) {
                // Fungsi untuk memformat datetime ke jam genap (menit 00)
                function formatToEvenHour(value) {
                    if (!value) return '';
                    
                    const date = new Date(value);
                    // Set menit dan detik ke 0
                    date.setMinutes(0);
                    date.setSeconds(0);
                    date.setMilliseconds(0);
                    
                    // Format kembali ke format datetime-local (YYYY-MM-DDTHH:mm)
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0');
                    const day = String(date.getDate()).padStart(2, '0');
                    const hours = String(date.getHours()).padStart(2, '0');
                    return `${year}-${month}-${day}T${hours}:00`;
                }
                
                // Event listener untuk memastikan menit selalu 00 saat change
                dateInput.addEventListener('change', function() {
                    const value = this.value;
                    if (value) {
                        const formatted = formatToEvenHour(value);
                        if (this.value !== formatted) {
                            this.value = formatted;
                        }
                    }
                });
                
                // Validasi saat input (real-time)
                dateInput.addEventListener('input', function() {
                    const value = this.value;
                    if (value) {
                        const date = new Date(value);
                        const minutes = date.getMinutes();
                        
                        // Jika menit bukan 00, set ke 00
                        if (minutes !== 0) {
                            const formatted = formatToEvenHour(value);
                            this.value = formatted;
                        }
                    }
                });
                
                // Validasi sebelum submit form
                const form = dateInput.closest('form');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        const value = dateInput.value;
                        if (value) {
                            const formatted = formatToEvenHour(value);
                            if (dateInput.value !== formatted) {
                                dateInput.value = formatted;
                            }
                            
                            // Double check: pastikan menit adalah 00
                            const date = new Date(dateInput.value);
                            if (date.getMinutes() !== 0) {
                                e.preventDefault();
                                alert('Waktu reservasi harus jam genap (contoh: 12:00, 13:00, 14:00).');
                                dateInput.focus();
                                return false;
                            }
                        }
                    });
                }
            }

            // Handler untuk tombol plus/minus quantity di kartu menu
            document.querySelectorAll('.qty-btn').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    const inputId = this.getAttribute('data-input-id');
                    const type = this.getAttribute('data-type');
                    const input = document.getElementById(inputId);
                    if (!input) return;

                    let current = parseInt(input.value || '0', 10);
                    if (type === 'minus') {
                        current = Math.max(0, current - 1);
                    } else if (type === 'plus') {
                        current = current + 1;
                    }
                    input.value = current;
                });
            });
        });
    </script>
</x-app-layout>
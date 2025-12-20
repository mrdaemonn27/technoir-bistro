<x-app-layout>
    <div class="py-12 bg-[#FFF8F5] min-h-screen" 
         x-data="{ showModal: false, modalTitle: '', modalMessage: '' }"
         @notify.window="showModal = true; modalTitle = $event.detail.title; modalMessage = $event.detail.message">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <div class="text-center mb-10">
                <span class="text-[#E5A024] font-serif italic text-xl">Change Plans</span>
                <h2 class="text-3xl font-bold text-[#2D2D2D]">Ubah Reservasi</h2>
            </div>

            <form action="{{ route('reservations.update', $reservation->id) }}" method="POST">
                @csrf
                @method('PUT')

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    
                    {{-- Detail Reservasi --}}
                    <div class="lg:col-span-1">
                        <div class="bg-white p-6 rounded-xl shadow-lg border-t-4 border-[#E5A024] sticky top-24">
                            <h3 class="text-xl font-bold text-[#2D2D2D] mb-6 border-b pb-2">Detail Reservasi</h3>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Waktu Kedatangan</label>
                                <input type="datetime-local" 
                                       name="reservation_date" 
                                       id="reservation_date"
                                       value="{{ \Carbon\Carbon::parse($reservation->reservation_date)->startOfHour()->format('Y-m-d\TH:i') }}"
                                       min="{{ \Carbon\Carbon::now()->addHour()->startOfHour()->format('Y-m-d\TH:i') }}"
                                       step="3600"
                                       class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024] @error('reservation_date') border-red-500 @enderror" 
                                       required>
                                @error('reservation_date')
                                    <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                @enderror
                                <p class="text-xs text-gray-500 mt-1">Pilih jam genap (contoh: 12:00, 13:00, 14:00)</p>
                            </div>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Pilih Meja</label>
                                <select name="table_id" id="table_id" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024] @error('table_id') border-red-500 @enderror" required>
                                    @foreach($tables as $table)
                                        <option value="{{ $table->id }}" data-capacity="{{ $table->capacity }}" {{ $reservation->table_id == $table->id ? 'selected' : '' }}>
                                            Meja {{ $table->table_number }} ({{ $table->capacity }} Org) - {{ $table->location }}
                                        </option>
                                    @endforeach
                                </select>
                                @error('table_id')
                                    <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                @enderror
                            </div>

                            <div class="mb-4">
                                <label class="block text-gray-600 text-sm font-bold mb-2">Jumlah Tamu</label>
                                <input type="number" name="guest_count" id="guest_count" min="1" value="{{ $reservation->guest_count }}" class="w-full border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024] @error('guest_count') border-red-500 @enderror" required>
                                @error('guest_count')
                                    <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                @enderror
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
                                        $existingItem = $reservation->menus->find($menu->id);
                                        $currentQty = $existingItem ? $existingItem->pivot->quantity : 0;
                                    @endphp

                                    <div class="flex items-center bg-[#FFF8F5] p-3 rounded-lg border border-gray-100 hover:border-[#E5A024] transition">
                                        <div class="relative w-16 h-16 mr-4 flex-shrink-0">
                                            <img src="{{ filter_var($menu->image, FILTER_VALIDATE_URL) ? $menu->image : asset('storage/' . $menu->image) }}" 
                                                 class="w-full h-full object-cover rounded-md"
                                                 onerror="this.src='https://placehold.co/100x100/E5E5E5/555?text=No+Img'">
                                        </div>
                                        
                                        <div class="flex-1 min-w-0">
                                            <h4 class="font-bold text-[#2D2D2D] text-sm truncate">{{ $menu->name }}</h4>
                                            <p class="text-[#E5A024] font-bold text-xs">Rp {{ number_format($menu->price, 0, ',', '.') }}</p>
                                        </div>

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

        {{-- Custom Modal Notification --}}
        <div x-show="showModal" 
             x-transition:enter="transition ease-out duration-300"
             x-transition:enter-start="opacity-0"
             x-transition:enter-end="opacity-100"
             x-transition:leave="transition ease-in duration-200"
             x-transition:leave-start="opacity-100"
             x-transition:leave-end="opacity-0"
             class="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm"
             style="display: none;">
            <div @click.away="showModal = false" 
                 class="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden transform transition-all border-t-4 border-[#E5A024]">
                <div class="p-6">
                    <div class="flex items-center justify-center w-12 h-12 mx-auto bg-orange-100 rounded-full mb-4">
                        <svg class="w-6 h-6 text-[#E5A024]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-center text-[#2D2D2D] mb-2" x-text="modalTitle"></h3>
                    <p class="text-gray-600 text-center mb-6" x-text="modalMessage"></p>
                    <div class="flex justify-center">
                        <button @click="showModal = false" 
                                class="bg-[#2D2D2D] hover:bg-[#E5A024] text-white font-bold py-2 px-8 rounded-full transition duration-300 focus:outline-none">
                            Mengerti
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('reservation_date');
            
            function showNotification(title, message) {
                window.dispatchEvent(new CustomEvent('notify', {
                    detail: { title: title, message: message }
                }));
            }

            if (dateInput) {
                function formatToEvenHour(value) {
                    if (!value) return '';
                    const date = new Date(value);
                    date.setMinutes(0); date.setSeconds(0); date.setMilliseconds(0);
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0');
                    const day = String(date.getDate()).padStart(2, '0');
                    const hours = String(date.getHours()).padStart(2, '0');
                    return `${year}-${month}-${day}T${hours}:00`;
                }
                
                dateInput.addEventListener('change', function() {
                    if (this.value) {
                        const formatted = formatToEvenHour(this.value);
                        if (this.value !== formatted) this.value = formatted;
                    }
                });
                
                const form = dateInput.closest('form');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        const value = dateInput.value;
                        if (value) {
                            const date = new Date(value);
                            if (date.getMinutes() !== 0) {
                                e.preventDefault();
                                showNotification('Waktu Tidak Valid', 'Waktu reservasi harus jam genap (contoh: 12:00, 13:00).');
                                dateInput.focus();
                                return false;
                            }

                            const tableSelect = document.getElementById('table_id');
                            const guestInput = document.getElementById('guest_count');
                            if (tableSelect && guestInput) {
                                const capacity = parseInt(tableSelect.options[tableSelect.selectedIndex].getAttribute('data-capacity'));
                                const guests = parseInt(guestInput.value);
                                if (guests > capacity) {
                                    e.preventDefault();
                                    showNotification('Kapasitas Meja Terbatas', `Maaf, Meja yang Anda pilih hanya untuk maksimal ${capacity} orang. Silakan pilih meja lain atau kurangi jumlah tamu.`);
                                    guestInput.focus();
                                    return false;
                                }
                            }
                        }
                    });
                }
            }
        });
    </script>
</x-app-layout>
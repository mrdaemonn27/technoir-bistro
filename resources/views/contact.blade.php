<x-app-layout>
    {{-- TEMA: Background Cream (#FFF8F5) --}}
    <div class="py-12 bg-[#FFF8F5] min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            {{-- Header Title --}}
            <div class="text-center mb-12">
                <span class="text-[#E5A024] font-serif italic text-xl">Get in Touch</span>
                <h2 class="text-4xl font-bold text-[#2D2D2D] mt-2">Hubungi Kami</h2>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                
                <!-- Kolom Kiri: Informasi Kontak (Card Putih) -->
                <div class="bg-white overflow-hidden shadow-lg sm:rounded-xl p-8 border-t-4 border-[#E5A024]">
                    <h3 class="text-2xl font-bold text-[#2D2D2D] mb-6">Contact Info</h3>
                    <p class="text-gray-600 mb-8 leading-relaxed">
                        Punya pertanyaan tentang menu kami atau ingin mengadakan acara khusus? Jangan ragu untuk menghubungi kami. Tim Technoir Bistro siap membantu Anda.
                    </p>

                    <div class="space-y-8">
                        <!-- Alamat -->
                        <div class="flex items-start group">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-full bg-[#FFF8F5] text-[#E5A024] group-hover:bg-[#E5A024] group-hover:text-white transition duration-300">
                                    <!-- Icon Map -->
                                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-4">
                                <h4 class="text-lg font-bold text-[#2D2D2D]">Lokasi</h4>
                                <p class="mt-1 text-gray-600">
                                    Jl. Braga No. 100<br>
                                    Bandung, Jawa Barat
                                </p>
                            </div>
                        </div>

                        <!-- Telepon -->
                        <div class="flex items-start group">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-full bg-[#FFF8F5] text-[#E5A024] group-hover:bg-[#E5A024] group-hover:text-white transition duration-300">
                                    <!-- Icon Phone -->
                                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-4">
                                <h4 class="text-lg font-bold text-[#2D2D2D]">Telepon</h4>
                                <p class="mt-1 text-gray-600">
                                    +62 812 3456 7890 (Reservasi)<br>
                                    +62 22 4234 5678 (Office)
                                </p>
                            </div>
                        </div>

                        <!-- Jam Buka -->
                        <div class="flex items-start group">
                            <div class="flex-shrink-0">
                                <div class="flex items-center justify-center h-12 w-12 rounded-full bg-[#FFF8F5] text-[#E5A024] group-hover:bg-[#E5A024] group-hover:text-white transition duration-300">
                                    <!-- Icon Clock -->
                                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-4">
                                <h4 class="text-lg font-bold text-[#2D2D2D]">Jam Operasional</h4>
                                <p class="mt-1 text-gray-600">
                                    Senin - Jumat: 10:00 - 22:00<br>
                                    Sabtu - Minggu: 10:00 - 23:00
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Kolom Kanan: Form Pesan (Card Putih) -->
                <div class="bg-white overflow-hidden shadow-lg sm:rounded-xl p-8 border-t-4 border-[#2D2D2D]">
                    <h3 class="text-2xl font-bold text-[#2D2D2D] mb-6">Kirim Pesan</h3>
                    
                    @if(session('success'))
                        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4">
                            {{ session('success') }}
                        </div>
                    @endif

                    <form action="{{ route('contact.store') }}" method="POST">
                        @csrf
                        <div class="grid grid-cols-1 gap-6">
                            <div>
                                <label for="name" class="block text-sm font-bold text-gray-700 mb-2">Nama Lengkap</label>
                                <input type="text" name="name" id="name" class="mt-1 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" placeholder="Nama Anda" required>
                            </div>

                            <div>
                                <label for="email" class="block text-sm font-bold text-gray-700 mb-2">Email Address</label>
                                <input type="email" name="email" id="email" class="mt-1 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" placeholder="email@contoh.com" required>
                            </div>

                            <div>
                                <label for="message" class="block text-sm font-bold text-gray-700 mb-2">Pesan</label>
                                <textarea id="message" name="message" rows="4" class="mt-1 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md focus:ring-[#E5A024] focus:border-[#E5A024]" placeholder="Tulis pesan Anda di sini..." required></textarea>
                            </div>

                            <div>
                                <button type="submit" class="w-full flex justify-center py-3 px-4 border border-transparent rounded-full shadow-lg text-sm font-bold text-white bg-[#2D2D2D] hover:bg-[#E5A024] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#E5A024] transition duration-300">
                                    Kirim Pesan
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
</x-app-layout>
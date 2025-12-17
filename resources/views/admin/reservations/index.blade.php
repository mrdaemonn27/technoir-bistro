<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
            {{ __('Reservasi Masuk') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            
            <!-- Notifikasi Sukses -->
            @if(session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                    <span class="block sm:inline">{{ session('success') }}</span>
                </div>
            @endif
            
            <!-- Notifikasi Warning (Hapus) -->
            @if(session('warning'))
                <div class="bg-yellow-100 border border-yellow-400 text-yellow-700 px-4 py-3 rounded relative mb-4" role="alert">
                    <span class="block sm:inline">{{ session('warning') }}</span>
                </div>
            @endif

            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">
                    
                    <div class="overflow-x-auto relative shadow-md sm:rounded-lg">
                        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
                            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
                                <tr>
                                    <th scope="col" class="py-3 px-6">ID</th>
                                    <th scope="col" class="py-3 px-6">Pemesan</th>
                                    <th scope="col" class="py-3 px-6">Jadwal</th>
                                    <th scope="col" class="py-3 px-6">Meja & Tamu</th>
                                    <th scope="col" class="py-3 px-6">Status</th>
                                    <th scope="col" class="py-3 px-6 text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse ($reservations as $reservation)
                                    <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
                                        <td class="py-4 px-6 font-medium text-gray-900 whitespace-nowrap dark:text-white">
                                            #{{ $reservation->id }}
                                        </td>
                                        <td class="py-4 px-6">
                                            <div class="font-semibold">{{ $reservation->user->username ?? 'Guest' }}</div>
                                            <div class="text-xs text-gray-400">{{ $reservation->user->email ?? '-' }}</div>
                                        </td>
                                        <td class="py-4 px-6">
                                            {{ \Carbon\Carbon::parse($reservation->reservation_date)->format('d M Y') }} <br>
                                            <span class="font-bold text-indigo-500">{{ \Carbon\Carbon::parse($reservation->reservation_date)->format('H:i') }}</span>
                                        </td>
                                        <td class="py-4 px-6">
                                            <div>{{ $reservation->table->name ?? 'Meja Dihapus' }} <span class="text-xs">({{ $reservation->table->location ?? '-' }})</span></div>
                                            <div class="text-xs text-gray-500">{{ $reservation->guest_count }} Orang</div>
                                        </td>
                                        <td class="py-4 px-6">
                                            <form action="{{ route('admin.reservations.update', $reservation->id) }}" method="POST">
                                                @csrf
                                                @method('PUT')
                                                <select name="status" onchange="this.form.submit()" class="text-xs border-gray-300 rounded-md shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 dark:bg-gray-700 dark:border-gray-600 dark:text-white 
                                                    {{ $reservation->status === 'confirmed' ? 'text-green-600 font-bold' : '' }}
                                                    {{ $reservation->status === 'cancelled' ? 'text-red-600' : '' }}
                                                    {{ $reservation->status === 'pending' ? 'text-yellow-600' : '' }}">
                                                    <option value="pending" {{ $reservation->status == 'pending' ? 'selected' : '' }}>Pending</option>
                                                    <option value="confirmed" {{ $reservation->status == 'confirmed' ? 'selected' : '' }}>Confirmed</option>
                                                    <option value="completed" {{ $reservation->status == 'completed' ? 'selected' : '' }}>Completed</option>
                                                    <option value="cancelled" {{ $reservation->status == 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                                                </select>
                                            </form>
                                        </td>
                                        <td class="py-4 px-6 text-center">
                                            <form action="{{ route('admin.reservations.destroy', $reservation->id) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin menghapus reservasi ini?');" class="inline-block">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="text-red-600 hover:text-red-900 dark:text-red-500 dark:hover:text-red-400">
                                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="7" class="py-4 px-6 text-center text-gray-500 dark:text-gray-400">
                                            Belum ada reservasi masuk.
                                        </td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination -->
                    <div class="mt-4">
                        {{ $reservations->links() }}
                    </div>

                </div>
            </div>
        </div>
    </div>
</x-app-layout>
<nav x-data="{ open: false }" class="bg-white dark:bg-gray-900 border-b border-gray-100 dark:border-gray-800 sticky top-0 z-50 shadow-sm">
    <!-- Primary Navigation Menu -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-20"> {{-- Tinggi navbar sedikit ditambah agar lega --}}
            
            <!-- Kiri: Logo & Menu Utama -->
            <div class="flex">
                <!-- Logo -->
                <div class="shrink-0 flex items-center">
                    <a href="{{ route('home') }}">
                        <x-application-logo class="block h-20 w-auto fill-current" />
                    </a>
                </div>

                <!-- Navigation Links (Desktop) -->
                <div class="hidden space-x-8 sm:-my-px sm:ms-10 sm:flex">
                    {{-- 1. HOME --}}
                    <x-nav-link :href="route('home')" :active="request()->routeIs('home')">
                        HOME
                    </x-nav-link>

                    {{-- 2. ABOUT (Link ke bagian About di Homepage) --}}
                    <x-nav-link :href="route('about')" :active="request()->routeIs('about')">
                        ABOUT
                    </x-nav-link>
                    
                    {{-- 3. MENU --}}
                    <x-nav-link :href="route('menu.index')" :active="request()->routeIs('menu.index')">
                        MENU
                    </x-nav-link>

                    {{-- 4. FAVORITES (Menu Favorit User) --}}
                    @auth
                        @if(!Auth::user()->is_admin)
                            <x-nav-link :href="route('favorites.index')" :active="request()->routeIs('favorites.index')">
                                FAVORITES
                            </x-nav-link>
                        @endif
                    @endauth

                    {{-- 5. RESERVATIONS (Riwayat / Daftar) --}}
                    @auth
                        {{-- HANYA TAMPIL JIKA BUKAN ADMIN --}}
                        @if(!Auth::user()->is_admin)
                            <x-nav-link :href="route('reservations.index')" :active="request()->routeIs('reservations.index')">
                                RESERVATIONS
                            </x-nav-link>
                        @endif
                    @endauth

                    {{-- 6. CONTACT (Link ke bagian Footer/Contact) --}}
                    <x-nav-link :href="route('contact')" :active="request()->routeIs('contact')">
                        CONTACT
                    </x-nav-link>
                </div>
            </div>

            <!-- Kanan: CTA & User Dropdown -->
            <div class="hidden sm:flex sm:items-center sm:ms-6 gap-4">
                
                {{-- TOMBOL AKSI (CTA): BOOK A TABLE / DASHBOARD ADMIN --}}
                @auth
                    @if(Auth::user()->is_admin)
                        <a href="{{ route('admin.index') }}" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2.5 px-6 rounded-full text-xs tracking-widest uppercase transition shadow-lg shadow-indigo-500/30 transform hover:scale-105">
                            Dashboard Admin
                        </a>
                    @else
                        <a href="{{ route('reservations.create') }}" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2.5 px-6 rounded-full text-xs tracking-widest uppercase transition shadow-lg shadow-indigo-500/30 transform hover:scale-105">
                            Book a Table
                        </a>
                    @endif
                @else
                    <a href="{{ route('reservations.create') }}" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2.5 px-6 rounded-full text-xs tracking-widest uppercase transition shadow-lg shadow-indigo-500/30 transform hover:scale-105">
                        Book a Table
                    </a>
                @endauth

                {{-- User Dropdown / Login Links --}}
                @auth
                    <x-dropdown align="right" width="48">
                        <x-slot name="trigger">
                            <button class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-gray-500 dark:text-gray-400 bg-white dark:bg-gray-900 hover:text-gray-700 dark:hover:text-gray-300 focus:outline-none transition ease-in-out duration-150">
                                <div>{{ Auth::user()->username }}</div>
                                <div class="ms-1">
                                    <svg class="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                                    </svg>
                                </div>
                            </button>
                        </x-slot>

                        <x-slot name="content">
                            <x-dropdown-link :href="route('profile.edit')">
                                {{ __('Profile') }}
                            </x-dropdown-link>

                            <!-- Dashboard User (Hanya muncul jika BUKAN admin) -->
                            @if(!Auth::user()->is_admin)
                                <x-dropdown-link :href="route('dashboard')">
                                    {{ __('Dashboard') }}
                                </x-dropdown-link>
                            @endif

                            <!-- Dashboard Admin (Hanya muncul jika Admin) -->
                            @if(Auth::user()->is_admin)
                                <x-dropdown-link :href="route('admin.index')">
                                    {{ __('Admin Dashboard') }}
                                </x-dropdown-link>
                            @endif

                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <x-dropdown-link :href="route('logout')"
                                        onclick="event.preventDefault();
                                                    this.closest('form').submit();">
                                    {{ __('Log Out') }}
                                </x-dropdown-link>
                            </form>
                        </x-slot>
                    </x-dropdown>
                @else
                    <div class="flex items-center gap-4 text-sm font-medium">
                        <a href="{{ route('login') }}" class="text-gray-600 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-white transition">Log in</a>
                        @if (Route::has('register'))
                            <a href="{{ route('register') }}" class="text-gray-600 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-white transition">Register</a>
                        @endif
                    </div>
                @endguest
            </div>

            <!-- Hamburger (Mobile Menu Trigger) -->
            <div class="-me-2 flex items-center sm:hidden">
                <button @click="open = ! open" class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 dark:text-gray-500 hover:text-gray-500 dark:hover:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-900 focus:outline-none transition duration-150 ease-in-out">
                    <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                        <path :class="{'hidden': open, 'inline-flex': ! open }" class="inline-flex" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        <path :class="{'hidden': ! open, 'inline-flex': open }" class="hidden" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>
    </div>

    <!-- Responsive Navigation Menu (Mobile) -->
    <div :class="{'block': open, 'hidden': ! open}" class="hidden sm:hidden bg-gray-50 dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
        <div class="pt-2 pb-3 space-y-1">
            <x-responsive-nav-link :href="route('home')" :active="request()->routeIs('home')">
                HOME
            </x-responsive-nav-link>
            <x-responsive-nav-link :href="route('about')" :active="request()->routeIs('about')">
                ABOUT
            </x-responsive-nav-link>
            <x-responsive-nav-link :href="route('menu.index')" :active="request()->routeIs('menu.index')">
                MENU
            </x-responsive-nav-link>
            
            @auth
                {{-- HANYA TAMPIL JIKA BUKAN ADMIN --}}
                @if(!Auth::user()->is_admin)
                    <x-responsive-nav-link :href="route('reservations.index')" :active="request()->routeIs('reservations.index')">
                        RESERVATIONS
                    </x-responsive-nav-link>
                @endif
            @endauth

            <x-responsive-nav-link :href="route('contact')" :active="request()->routeIs('contact')">
                CONTACT
            </x-responsive-nav-link>
            
            {{-- CTA Mobile --}}
            <div class="px-4 mt-4">
                @auth
                    @if(Auth::user()->is_admin)
                        <a href="{{ route('admin.index') }}" class="block w-full text-center bg-indigo-600 text-white font-bold py-3 rounded-lg shadow-lg">
                            DASHBOARD ADMIN
                        </a>
                    @else
                        <a href="{{ route('reservations.create') }}" class="block w-full text-center bg-indigo-600 text-white font-bold py-3 rounded-lg shadow-lg">
                            BOOK A TABLE
                        </a>
                    @endif
                @else
                    <a href="{{ route('reservations.create') }}" class="block w-full text-center bg-indigo-600 text-white font-bold py-3 rounded-lg shadow-lg">
                        BOOK A TABLE
                    </a>
                @endauth
            </div>
        </div>

        <!-- Responsive Settings Options -->
        @auth
            <div class="pt-4 pb-1 border-t border-gray-200 dark:border-gray-600">
                <div class="px-4">
                    <div class="font-medium text-base text-gray-800 dark:text-gray-200">{{ Auth::user()->username }}</div>
                    <div class="font-medium text-sm text-gray-500">{{ Auth::user()->email }}</div>
                </div>

                <div class="mt-3 space-y-1">
                    <x-responsive-nav-link :href="route('profile.edit')">
                        {{ __('Profile') }}
                    </x-responsive-nav-link>

                    @if(!Auth::user()->is_admin)
                        <x-responsive-nav-link :href="route('dashboard')">
                            {{ __('Dashboard') }}
                        </x-responsive-nav-link>
                    @endif

                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <x-responsive-nav-link :href="route('logout')"
                                onclick="event.preventDefault();
                                            this.closest('form').submit();">
                            {{ __('Log Out') }}
                        </x-responsive-nav-link>
                    </form>
                </div>
            </div>
        @else
             <div class="pt-4 pb-4 border-t border-gray-200 dark:border-gray-600">
                <div class="space-y-1">
                    <x-responsive-nav-link :href="route('login')">
                        {{ __('Log In') }}
                    </x-responsive-nav-link>
                    @if (Route::has('register'))
                        <x-responsive-nav-link :href="route('register')">
                            {{ __('Register') }}
                        </x-responsive-nav-link>
                    @endif
                </div>
            </div>
        @endauth
    </div>
</nav>
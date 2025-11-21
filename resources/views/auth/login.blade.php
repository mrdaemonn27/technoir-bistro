<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Technoir Bistro Login</title>
    @vite('resources/css/app.css')
</head>

<body class="bg-[#FFF8F5] min-h-screen flex items-center justify-center">
    <div class="flex flex-col items-center">
        <!-- Logo + Title -->
        <h1 class="text-5xl font-extrabold text-[#2D2D2D] mb-2">Technoir <span class="text-[#E5A024]">Bistro</span></h1>
        <p class="text-[#2D2D2D] text-2xl">welcome back</p>
        <p class="text-gray-600 text-lg mb-6">Please login to your account</p>

        <!-- Session Status -->
        <x-auth-session-status class="mb-4" :status="session('status')" />

        <!-- Card -->
        <div class="bg-white w-[420px] rounded-lg shadow-lg p-8">
            <form method="POST" action="{{ route('login') }}">
                @csrf

                <!-- Email Address -->
                <label for="email" class="block text-[#2D2D2D] mb-1">Email</label>
                <input 
                    id="email"
                    type="email" 
                    name="email"
                    :value="old('email')" 
                    required 
                    autofocus 
                    autocomplete="username"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-[#E5A024] focus:border-[#E5A024]"
                    placeholder="Enter your email"
                />
                <x-input-error :messages="$errors->get('email')" class="mt-2 text-red-500 text-sm" />

                <!-- Password -->
                <label for="password" class="block text-[#2D2D2D] mt-4 mb-1">Password</label>
                <input 
                    id="password"
                    type="password" 
                    name="password"
                    required 
                    autocomplete="current-password"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-[#E5A024] focus:border-[#E5A024]"
                    placeholder="Enter your password"
                />
                <x-input-error :messages="$errors->get('password')" class="mt-2 text-red-500 text-sm" />

                <!-- Remember Me -->
                <div class="block mt-4">
                    <label for="remember_me" class="inline-flex items-center">
                        <input id="remember_me" type="checkbox" class="rounded dark:bg-gray-900 border-gray-300 dark:border-gray-700 text-[#E5A024] shadow-sm focus:ring-[#E5A024] dark:focus:ring-[#E5A024] dark:focus:ring-offset-gray-800" name="remember">
                        <span class="ms-2 text-sm text-[#2D2D2D]">{{ __('Remember me') }}</span>
                    </label>
                </div>

                <!-- Sign In Button -->
                <button type="submit" class="w-full bg-[#1A1A1A] text-white py-2 rounded-md mt-6 hover:bg-[#E5A024] transition duration-300">
                    Sign In
                </button>

                <!-- Forgot Password -->
                <div class="flex items-center justify-between mt-4">
                    @if (Route::has('password.request'))
                        <a class="text-sm text-[#2D2D2D] underline hover:text-[#E5A024]" href="{{ route('password.request') }}">
                            {{ __('Forgot your password?') }}
                        </a>
                    @endif
                </div>

                <!-- Signup -->
                <p class="text-center text-sm text-[#2D2D2D] mt-6">
                    Don't have an account?
                    <a href="{{ route('register') }}" class="text-[#E5A024] font-semibold hover:underline">Signup</a>
                </p>
            </form>
        </div>
    </div>
</body>
</html>
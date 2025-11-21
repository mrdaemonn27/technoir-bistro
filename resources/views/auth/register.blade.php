<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Technoir Bistro Register</title>
    @vite('resources/css/app.css')
</head>

<body class="bg-[#FFF8F5] min-h-screen flex items-center justify-center">
    <div class="flex flex-col items-center">
        <!-- Logo + Title -->
        <h1 class="text-5xl font-extrabold text-[#2D2D2D] mb-2">Technoir <span class="text-[#E5A024]">Bistro</span></h1>
        <p class="text-[#2D2D2D] text-2xl">create account</p>
        <p class="text-gray-600 text-lg mb-6">Please fill in the details to register</p>

        <!-- Card -->
        <div class="bg-white w-[420px] rounded-lg shadow-lg p-8">
            <form method="POST" action="{{ route('register') }}">
                @csrf

                <!-- Username -->
                <label for="username" class="block text-[#2D2D2D] mb-1">Username</label>
                <input 
                    id="username"
                    type="text" 
                    name="username"
                    :value="old('username')" 
                    required 
                    autofocus 
                    autocomplete="username"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-[#E5A024] focus:border-[#E5A024]"
                    placeholder="Enter your username"
                />
                <x-input-error :messages="$errors->get('username')" class="mt-2 text-red-500 text-sm" />

                <!-- Email Address -->
                <label for="email" class="block text-[#2D2D2D] mt-4 mb-1">Email</label>
                <input 
                    id="email"
                    type="email" 
                    name="email"
                    :value="old('email')" 
                    required 
                    autocomplete="email"
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
                    autocomplete="new-password"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-[#E5A024] focus:border-[#E5A024]"
                    placeholder="Enter your password"
                />
                <x-input-error :messages="$errors->get('password')" class="mt-2 text-red-500 text-sm" />

                <!-- Confirm Password -->
                <label for="password_confirmation" class="block text-[#2D2D2D] mt-4 mb-1">Confirm Password</label>
                <input 
                    id="password_confirmation"
                    type="password" 
                    name="password_confirmation"
                    required 
                    autocomplete="new-password"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-[#E5A024] focus:border-[#E5A024]"
                    placeholder="Confirm your password"
                />
                <x-input-error :messages="$errors->get('password_confirmation')" class="mt-2 text-red-500 text-sm" />

                <!-- Sign Up Button -->
                <button type="submit" class="w-full bg-[#1A1A1A] text-white py-2 rounded-md mt-6 hover:bg-[#E5A024] transition duration-300">
                    Sign Up
                </button>

                <!-- Login -->
                <p class="text-center text-sm text-[#2D2D2D] mt-6">
                    Already have an account?
                    <a href="{{ route('login') }}" class="text-[#E5A024] font-semibold hover:underline">Login</a>
                </p>
            </form>
        </div>
    </div>
</body>
</html>
<?php

// app/Http/Middleware/AdminMiddleware.php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        // Cek apakah user sudah login DAN user adalah admin
        if (auth()->check() && auth()->user()->is_admin) {
            return $next($request); // Lanjutkan ke rute admin
        }

        // Jika tidak, tendang kembali ke halaman dashboard biasa
        return redirect('/dashboard');
    }
}

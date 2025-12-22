<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthManualTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 1. Render Halaman: Pastikan halaman login bisa dibuka (Status 200).
     */
    public function test_login_screen_can_be_rendered(): void
    {
        $response = $this->get('/login');

        $response->assertStatus(200);
    }

    /**
     * 2. Login Berhasil: User yang sudah ada di database bisa login dengan email dan password yang benar.
     */
    public function test_users_can_authenticate_using_the_login_screen(): void
    {
        $user = User::factory()->create();

        $response = $this->post('/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $this->assertAuthenticated();
        $response->assertRedirect('/dashboard');
    }

    /**
     * 3. Login Gagal: User tidak bisa login jika password salah.
     */
    public function test_users_can_not_authenticate_with_invalid_password(): void
    {
        $user = User::factory()->create();

        $response = $this->post('/login', [
            'email' => $user->email,
            'password' => 'wrong-password',
        ]);

        $this->assertGuest();
        $response->assertSessionHasErrors('email');
    }

    /**
     * 4. Validasi Register: User tidak bisa register jika email kosong atau password tidak match.
     */
    public function test_registration_validation_fails_with_missing_email_or_mismatched_password(): void
    {
        // Gagal karena email kosong
        $response1 = $this->post('/register', [
            'username' => 'testuser',
            'name' => 'Test User',
            'email' => '',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $response1->assertSessionHasErrors('email');

        // Gagal karena password tidak match
        $response2 = $this->post('/register', [
            'username' => 'testuser2',
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'different-password',
        ]);

        $response2->assertSessionHasErrors('password');
    }

    /**
     * 5. Register Berhasil: User baru berhasil terdaftar di database.
     */
    public function test_new_users_can_register(): void
    {
        $response = $this->post('/register', [
            'username' => 'testuser',
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $this->assertAuthenticated();
        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
        ]);
        $response->assertRedirect('/dashboard');
    }
}

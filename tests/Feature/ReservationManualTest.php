<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Table;
use App\Models\Menu;
use App\Models\Reservation;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;
use Tests\TestCase;

class ReservationManualTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 1. Reservation Form Account: Memastikan form reservasi bisa dibuka oleh user yang login.
     */
    public function test_authenticated_user_can_access_reservation_form(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get('/reservations/create');

        $response->assertStatus(200);
        $response->assertSee('Buat Reservasi'); // Asumsi teks ini ada di view
    }

    /**
     * 2. Guest Access: Guest tidak bisa akses reservation form.
     */
    public function test_guest_cannot_access_reservation_form(): void
    {
        $response = $this->get('/reservations/create');

        $response->assertRedirect('/login');
    }

    /**
     * 3. Successful Reservation: User bisa membuat reservasi dengan pre-order menu.
     */
    public function test_user_can_create_reservation_with_menus(): void
    {
        $user = User::factory()->create();
        $table = Table::factory()->create(['capacity' => 4]);
        $menu = Menu::factory()->create();

        $reservationDate = Carbon::now()->addDay()->setHour(14)->setMinute(0)->setSecond(0);

        $response = $this->actingAs($user)->post('/reservations', [
            'table_id' => $table->id,
            'reservation_date' => $reservationDate->toDateTimeString(),
            'guest_count' => 2,
            'notes' => '',
            'menus' => [
                $menu->id => 2, // 2 porsi
            ],
        ]);

        // Berdasarkan controller, redirect ke payments.create
        $response->assertRedirect('/payments/create?reservation_id=1');
        $this->assertDatabaseHas('reservations', [
            'user_id' => $user->id,
            'table_id' => $table->id,
            'guest_count' => 2,
        ]);

        // Cek apakah menu terhubung
        $reservation = Reservation::where('user_id', $user->id)->first();
        $this->assertEquals(1, $reservation->menus->count());
        $this->assertEquals(2, $reservation->menus->first()->pivot->quantity);
    }

    /**
     * 4. Capacity Validation: Gagal jika guest_count > capacity meja.
     */
    public function test_reservation_fails_if_guest_count_exceeds_capacity(): void
    {
        $user = User::factory()->create();
        $table = Table::factory()->create(['capacity' => 2]);

        $response = $this->actingAs($user)->post('/reservations', [
            'table_id' => $table->id,
            'reservation_date' => Carbon::now()->addDay()->setHour(18)->setMinute(0)->format('Y-m-d H:i:s'),
            'guest_count' => 5, // Melebihi kapasitas 2
        ]);

        $response->assertSessionHasErrors('guest_count');
    }

    /**
     * 5. Time Validation: Gagal jika menit tidak "00" (aturan jam genap).
     */
    public function test_reservation_fails_with_invalid_minute(): void
    {
        $user = User::factory()->create();
        $table = Table::factory()->create();

        $response = $this->actingAs($user)->post('/reservations', [
            'table_id' => $table->id,
            'reservation_date' => Carbon::now()->addDay()->setHour(18)->setMinute(30)->format('Y-m-d H:i:s'),
            'guest_count' => 2,
        ]);

        $response->assertSessionHasErrors('reservation_date');
    }

    /**
     * 6. User can see their own reservations.
     */
    public function test_user_can_view_their_reservations(): void
    {
        $user = User::factory()->create();
        $reservation = Reservation::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user)->get('/reservations');

        $response->assertStatus(200);
        // Format di view: l, d F Y (e.g. Tuesday, 21 October 2025)
        $response->assertSee($reservation->reservation_date->format('d F Y'));
    }

    /**
     * 7. User can cancel their reservation.
     */
    public function test_user_can_cancel_their_reservation(): void
    {
        $user = User::factory()->create();
        $reservation = Reservation::factory()->create(['user_id' => $user->id, 'status' => 'pending']);

        $response = $this->actingAs($user)->delete("/reservations/{$reservation->id}");

        $response->assertRedirect('/reservations');
        $this->assertDatabaseHas('reservations', [
            'id' => $reservation->id,
            'status' => 'cancelled',
        ]);
    }
}

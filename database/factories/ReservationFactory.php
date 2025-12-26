<?php

namespace Database\Factories;

use App\Models\Reservation;
use App\Models\User;
use App\Models\Table;
use Illuminate\Database\Eloquent\Factories\Factory;
use Carbon\Carbon;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Reservation>
 */
class ReservationFactory extends Factory
{
    protected $model = Reservation::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'table_id' => Table::factory(),
            'reservation_date' => Carbon::now()->addDay()->setMinute(0)->setSecond(0),
            'guest_count' => 2,
            'status' => 'pending',
            'notes' => $this->faker->sentence(),
        ];
    }
}

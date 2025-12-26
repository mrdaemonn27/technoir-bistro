<?php

namespace Database\Factories;

use App\Models\Table;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Table>
 */
class TableFactory extends Factory
{
    protected $model = Table::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'table_number' => $this->faker->unique()->bothify('??-##'),
            'capacity' => $this->faker->numberBetween(2, 6),
            'status' => 'available',
            'location' => $this->faker->randomElement(['Indoor', 'Outdoor', 'Rooftop']),
        ];
    }
}

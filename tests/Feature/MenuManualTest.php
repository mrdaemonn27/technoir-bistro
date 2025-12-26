<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Menu;
use App\Models\Category;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class MenuManualTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 1. Public Menu List: Memastikan daftar menu publik bisa dibuka dan menampilkan menu yang tersedia.
     */
    public function test_public_menu_page_renders_and_displays_available_items(): void
    {
        $availableMenu = Menu::factory()->create(['name' => 'Menu Tersedia', 'availability' => true]);
        $unavailableMenu = Menu::factory()->create(['name' => 'Menu Habis', 'availability' => false]);

        $response = $this->get('/menu');

        $response->assertStatus(200);
        $response->assertSee('Menu Tersedia');
        $response->assertDontSee('Menu Habis');
    }

    /**
     * 2. Admin Menu List: Admin bisa melihat daftar menu di panel admin.
     */
    public function test_admin_can_view_menu_list(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $menu = Menu::factory()->create();

        $response = $this->actingAs($admin)->get('/admin/menus');

        $response->assertStatus(200);
        $response->assertSee($menu->name);
    }

    /**
     * 3. Admin Create Menu: Admin bisa membuat menu baru.
     */
    public function test_admin_can_create_menu(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $category = Category::factory()->create();
        
        Storage::fake('public');
        $image = UploadedFile::fake()->create('pizza.jpg', 100, 'image/jpeg');

        $response = $this->actingAs($admin)->post('/admin/menus', [
            'name' => 'Pizza Deluxe',
            'description' => 'Pizza enak sekali',
            'price' => 50000,
            'category_id' => $category->id,
            'availability' => true,
            'image' => $image,
        ]);

        $response->assertRedirect('/admin/menus');
        $this->assertDatabaseHas('menus', ['name' => 'Pizza Deluxe']);
        
        // Cek apakah file benar-benar terupload
        $menu = Menu::where('name', 'Pizza Deluxe')->first();
        $this->assertTrue(Storage::disk('public')->exists($menu->image));
    }

    /**
     * 4. Admin Update Menu: Admin bisa mengedit menu.
     */
    public function test_admin_can_update_menu(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $menu = Menu::factory()->create(['name' => 'Menu Lama']);
        $newCategory = Category::factory()->create();

        $response = $this->actingAs($admin)->patch("/admin/menus/{$menu->id}", [
            'name' => 'Menu Baru',
            'price' => 75000,
            'category_id' => $newCategory->id,
            'availability' => true,
        ]);

        $response->assertRedirect('/admin/menus');
        $this->assertDatabaseHas('menus', ['id' => $menu->id, 'name' => 'Menu Baru', 'price' => 75000]);
    }

    /**
     * 5. Admin Delete Menu: Admin bisa menghapus menu.
     */
    public function test_admin_can_delete_menu(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $menu = Menu::factory()->create();

        $response = $this->actingAs($admin)->delete("/admin/menus/{$menu->id}");

        $response->assertRedirect('/admin/menus');
        $this->assertDatabaseMissing('menus', ['id' => $menu->id]);
    }

    /**
     * 6. Unauthorized Access: User biasa tidak bisa akses menu admin.
     */
    public function test_regular_user_cannot_access_admin_menus(): void
    {
        $user = User::factory()->create(['is_admin' => false]);

        $response = $this->actingAs($user)->get('/admin/menus');

        // AdminMiddleware mengalihkan user non-admin ke dashboard
        $response->assertRedirect('/dashboard');
    }
}

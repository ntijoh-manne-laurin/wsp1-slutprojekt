import { test, expect } from '@playwright/test';

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

test('Log in', async ({ page }) => {
  await page.goto('http://localhost:9292/users/login');

  await page.fill('input[name="username"]', 'Mannecool1337');
  await sleep(1000);
  await page.fill('input[name="password"]', 'hemligt123');
  await sleep(1000);
  await page.click('input[type="submit"]');


  await sleep(1000);
    
  await expect(page.getByRole('heading', { name: 'Hemsidan'})).toBeVisible();
});

test('Skapa och ta bort produkt', async ({ page }) => {
    const uniqueString = crypto.randomUUID();

    await page.goto('http://localhost:9292/users/login');

    await page.fill('input[name="username"]', 'Mannecool1337');
    await sleep(1000);
    await page.fill('input[name="password"]', 'hemligt123');
    await sleep(1000);
    await page.click('input[type="submit"]');
    await sleep(1000);

    // await page.getByRole('link', { name: 'New product' }).click();
   // await page.click('#newproduct');
    await page.goto('http://localhost:9292/products/new');

    await sleep(1000);

    await page.fill('input[name="name"]', uniqueString);
    await sleep(1000);

    await page.fill('input[name="description"]', "testprodukt");
    await sleep(1000);

    await page.fill('input[name="price"]', "500");
    await sleep(1000);
    
    await page.click('input[type="submit"]');
    await sleep(500);
    
    await page.getByRole('heading', { name: uniqueString }).click();
    await sleep(1000);

    await page.click('button:has-text("Delete")');
    await sleep(1000);

    await expect(page.getByText(uniqueString)).not.toBeAttached();
});

/*
test('get started link', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // Click the get started link.
  await page.getByRole('link', { name: 'Get started' }).click();

  // Expects page to have a heading with the name of Installation.
  await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
*/
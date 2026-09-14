<script>
  import { Form, page } from 'inertiax-svelte'
  import Input from '~/components/Input.svelte'
  import Socials from './_socials.svelte'

  const { close } = $props()
  let email = $state("")
  
  $effect(() => page.props.current_user && close(false))
</script>

<main>
  <section>
    <h3>
      Welcome back!
    </h3>
    <Form action="/session?email={email}" method="post">
      {#snippet children({ errors })}
        <Input id="email" bind:value={email} label="Email" {errors} />
        <Input name="password" label="Password" type="password" {errors} />
        <button class="btn primary w-full" type="submit">
          Sign in
        </button>
      {/snippet}
    </Form>
    <p class="text-right text-sm text-gray mt-2">
      <a href="/password_resets/new" data-replace>Forgot password?</a>
    </p>
    <Socials flow="login"/>
  </section>
  <section class="text-center text-gray">
    <p>
      Don't have an account?
      <a href="/user/new" data-replace>Sign up</a>
    </p>
  </section>
</main>


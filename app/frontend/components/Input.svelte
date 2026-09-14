<script>
  let { 
    value = $bindable(),
    name, 
    errors,
    label,
    tag = "input",
    ...rest } = $props()
  let error = $derived(errors[name])
</script>

<div class="field" class:error>
  <label for={name}>
    {label}
    {#if error}
      <span class="error">{error}</span>
    {/if}
  </label>
  {#if tag == "textarea"}
    <textarea bind:value this={tag} {name} placeholder="" onfocus={() => errors[name] = null} {...rest} ></textarea>
  {:else}
    <input bind:value this={tag} {name} placeholder="" onfocus={() => errors[name] = null} {...rest}/>
  {/if}
</div>

<style>
input, textarea {
  outline: none !important;
}
  .field {
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  margin-block: 1rem;
  display: flex;
  &:has(input:focus),
  &:has(textarea:focus) {
    border-color: var(--color-primary);
  }
  input, textarea {
    width: 100%;
    padding: 1rem;
  }
  label {
    padding: 1rem;
    position: absolute;
    pointer-events: none;
    transition: 0.2s ease all;
    color: #aaa;
  }
  &.error {
    border-color: #ff4d4d;
    label {
      color: #ff4d4d;
    }
  }
  &:has(input:focus) label,
  &:has(input:not(:placeholder-shown)) label,
  &:has(textarea:focus) label,
  &:has(textarea:not(:placeholder-shown)) label {
    font-size: 0.75rem;
    transform: translateY(-1rem);
  }
}
</style>
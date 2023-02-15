<script lang="ts">
  import { useFetchNui } from "@hooks/useFetchNui";
  import { useNuiEvent } from "@hooks/useNuiEvent";
  import { skills } from "@store/skills";
  import { isEnvBrowser } from "@utils/misc";
  import { onMount } from "svelte";
  import { cubicIn, cubicOut } from "svelte/easing";
  import { fly } from "svelte/transition";
  import Skill from "./Skill.svelte";
  let show = false;
  let search = "";

  useNuiEvent<boolean>("viewSkills", () => {
    show = true;
  });

  useNuiEvent<Skill[]>("updateSkills", (data) => {
    let skillsArray = [];
    data.forEach((skill) => {
      skillsArray.push(skill);
    });
    skills.set(skillsArray);
  });

  function handleClose() {
    if (!isEnvBrowser()) {
      useFetchNui("hideUI");
    }
    show = false;
  }

  onMount(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (show && ["Escape"].includes(e.code)) {
        if (!isEnvBrowser()) {
          useFetchNui("hideUI");
        }
        show = false;
      }
    };
    window.addEventListener("keydown", keyHandler);
    return () => window.removeEventListener("keydown", keyHandler);
  });
</script>

{#if show}
  <div
    class="container"
    in:fly={{ x: 1000, duration: 1000, easing: cubicOut }}
    out:fly={{ x: 1000, duration: 500, easing: cubicIn }}
  >
    <div
      class="p-3 flex items-center justify-between sticky top-0 bg-[#32323d]"
    >
      <p class="text-2xl font-semibold text-[#F8F8F8]">Skills</p>
      <button
        on:click={handleClose}
        class="bg-[#393A45] hover:bg-[#484957] rounded-md shadow-sm px-4 py-2 text-[#F8F8F8] font-medium transition-all"
        >Close</button
      >
    </div>
    <div class="px-3 py-2 w-full">
      <input
        type="text"
        bind:value={search}
        class="p-2 bg-[#393A45] text-[#F8F8F8] text-sm rounded-md w-full"
        placeholder="Skill Search"
      />
    </div>
    <div class="p-3 grid grid-cols-1 gap-4">
      {#each $skills.filter((skill) => skill.name
          .toLowerCase()
          .includes(search.toLowerCase())) as skill}
        <Skill
          skillData={{
            level: skill.level,
            name: skill.name,
            progress: skill.progress,
          }}
        />
      {/each}
    </div>
  </div>
{/if}

<style>
  .container {
    position: absolute;
    top: 50%;
    left: calc(90% - 1rem);
    transform: translate(-50%, -50%);
    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    overflow-y: scroll;
    border-radius: 5px;
    height: 65%;
    width: 20%;
    user-select: none;
    background-color: #32323d;
  }
</style>

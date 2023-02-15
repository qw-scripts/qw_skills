<script lang="ts">
  import Skills from "@components/Skills.svelte";
  import { debugData } from "@utils/debugData";

  debugData([
    {
      action: "viewSkills",
      data: null,
    },
  ]);
</script>

<main>
  <Skills />
</main>

<script lang="ts">
  import type { Skill } from "@interfaces/skill";

  export let skillData: Skill;
</script>

<div class="bg-[#393A45] rounded-md shadow-sm flex flex-col gap-3">
  <div class="p-3">
    <div class="flex items-center justify-between">
      <p class="font-semibold text-[#F8F8F8]">{skillData.name}</p>
      <p
        class="w-6 h-6 rounded-full p-2 bg-[#52E3C2] text-[#45817B] font-medium flex items-center justify-center"
      >
        {skillData.level}
      </p>
    </div>
    <div class="w-full bg-gray-200 rounded-full dark:bg-[#32323d] mt-3">
      <div
        class="bg-[#52E3C2] text-xs font-medium text-[#45817B] text-center p-0.5 leading-none rounded-full"
        style="width: {skillData.progress}%"
      >
        {skillData.progress}%
      </div>
    </div>
  </div>
</div>

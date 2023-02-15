import type { Skill } from "@interfaces/skill";
import { writable } from "svelte/store";

export const skills = writable<Skill[]>([]);

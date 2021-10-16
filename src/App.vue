<template>
  <h1>Generator</h1>
  <button @click="generate" class="bg-green-700 text-white p-2 px-3 rounded-full">Generate</button>
  <p id="blurb" class="grid grid-cols-5 grid-flow-col auto-cols-max">
    <span v-for="word of words" :key="word.word">{{ word.word }}&nbsp;</span>
  </p>
  <p id="info" class="grid grid-cols-5 grid-flow-col auto-cols-max">
    <span v-for="word of words" :key="word.word"
      >{{ word.partOfSpeech }}&nbsp;</span
    >
  </p>
</template>

<script setup>
import { ref } from "@vue/reactivity";
import axios from "axios";

const words = ref([]);

async function generate() {
  const total = 5;

  let responses = [];
  let partsOfSpeech = [
    "preposition",
    "conjunction",
    "noun",
    "pronoun",
    "verb",
    "adverb",
    "adjective",
  ];
  for (let i = 0; i < total; i++) {
    responses.push(
      axios.request({
        method: "GET",
        url: "https://wordsapiv1.p.rapidapi.com/words/",
        headers: {
          "x-rapidapi-host": "wordsapiv1.p.rapidapi.com",
          "x-rapidapi-key":
            "c79abe840bmsh5c471bf03d34f87p1c21a5jsn0ebeca62307f",
        },
        params: {
          random: true,
          partOfSpeech:
            partsOfSpeech[Math.floor(Math.random() * partsOfSpeech.length)],
          hasDetails: "definitions",
        },
      })
    );
  }

  responses = await Promise.all(responses);

  console.log(responses);

  let wordOrder = {
    pronoun: 2,
    adjective: 3,
    adverb: 4,
    verb: 5,
    noun: 6,
  };
  let sorted = responses
    .sort(() => Math.random() - 0.5)
    .map(({ data }) => data)
    .sort((a, b) => {
      let partA = wordOrder[a.results?.[0]?.partOfSpeech];
      let partB = wordOrder[b.results?.[0]?.partOfSpeech];
      if (partA === undefined) return Math.random() - 0.5;
      if (partB === undefined) return Math.random() - 0.5;
      if (partA > partB) return 1;
      if (partB > partA) return -1;
      return 0;
    });

  words.value = sorted.map((data) => ({
    word: data.word,
    partOfSpeech: data.results[0]?.partOfSpeech,
  }));
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>

<template>
  <div class="flex flex-col justify-center p-5">
    <h1>Generator</h1>
    <button @click="generate" class="fixed bottom-4 right-4 bg-green-700 hover:bg-green-500 text-white p-2 px-3 rounded-full m-auto">Generate</button>
    <draggable
        v-model="wordSlotsArray"
        item-key="id"
        class="flex flex-wrap gap-5 my-2"
        tag="div"
        ghost-class="ghost"
        :animation="200"
        @start="drag = true"
        @end="drag = false"
    >
      <template #item="{ element }">
        <div class="rounded-md bg-gray-200 p-5 cursor-move">
          <p>{{ element.word?.word }}</p>
          <p>{{ element.partOfSpeech }}</p>
          <div class="flex flex-row-reverse">
            <button
                class="hover:bg-gray-300 text-red-500 rounded-full h-12 w-12 flex items-center justify-center"
                @click="remove(element)"
            >
              <i class="material-icons">delete</i>
            </button>
          </div>
        </div>
      </template>
    </draggable>
    <div class="rounded-md bg-gray-200 p-5 flex gap-2">
      <select v-model="selectedPart">
        <option v-for="part of partsOfSpeech" :key="part">{{ part }}</option>
      </select>
      <button
          class="hover:bg-gray-300 active:bg-gray-400 rounded-full h-12 w-12 flex items-center justify-center"
          @click="add(selectedPart)"
      >
        <i class="material-icons">add</i>
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from "@vue/reactivity"
import axios from "axios"
import Draggable from 'vuedraggable'

const partsOfSpeech = ref([
  'noun',
  'pronoun',
  'verb',
  'adverb',
  'adjective',
  'preposition',
  'conjunction'
])
const selectedPart = ref("")
const wordSlots = reactive({
  1: { id: 1, partOfSpeech: 'noun',        word: {}, response: null, order: 1 },
  2: { id: 2, partOfSpeech: 'pronoun',     word: {}, response: null, order: 2 },
  3: { id: 3, partOfSpeech: 'verb',        word: {}, response: null, order: 3 },
  4: { id: 4, partOfSpeech: 'adverb',      word: {}, response: null, order: 4 },
  5: { id: 5, partOfSpeech: 'adjective',   word: {}, response: null, order: 5 },
  6: { id: 6, partOfSpeech: 'preposition', word: {}, response: null, order: 6 },
  7: { id: 7, partOfSpeech: 'conjunction', word: {}, response: null, order: 7 }
})
const wordSlotsArray = computed({
  get: () => Object.values(wordSlots).sort((a, b) => a.order - b.order),
  set: v  => {
    for (let i = 0; i < v.length; i++) {
      wordSlots[v[i].id] = {
        ...v[i],
        order: i
      }
    }
  }
})
const drag = ref(false)

function add(part) {
  wordSlots[wordSlotsArray.value.length + 1] = {
    id: wordSlotsArray.value.length + 1,
    partOfSpeech: part,
    word: {},
    response: null,
    order: wordSlotsArray.value.length + 1,
  }
}

function remove(slot) {
  delete wordSlots[slot.id]
}

async function generate() {
  const keys = Object.keys(wordSlots)

  for (let key of keys) {
    wordSlots[key].response = await axios.request({
      method: "GET",
      url: "https://wordsapiv1.p.rapidapi.com/words/",
      headers: {
        "x-rapidapi-host": "wordsapiv1.p.rapidapi.com",
        "x-rapidapi-key": process.env.VUE_APP_WORDS_API_KEY,
      },
      params: {
        random: true,
        partOfSpeech: wordSlots[key].partOfSpeech,
          // partsOfSpeech[Math.floor(Math.random() * partsOfSpeech.length)],
        hasDetails: "definitions",
      },
    })
  }

  // await Promise.all(Object.values(wordSlots).map(slot => slot.response))
    // .then(results => ) // lost it in Promise.all

  for (let key of Object.keys(wordSlots)) {
    let response = wordSlots[key].response
    let data = response?.data
    wordSlots[key].word = {
      word: data?.word,
      partOfSpeech: data?.results?.[0]?.partOfSpeech,
    }
  }
}
</script>

<style scoped>
@import url("https://fonts.googleapis.com/icon?family=Material+Icons");

.slide-move {
  transition: transform 0.5s;
}
.ghost {
  opacity: 0.5;
}
</style>

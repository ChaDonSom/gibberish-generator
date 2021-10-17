<template>
  <div class="flex flex-col justify-center p-5">
    <h1>Generator</h1>
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
        <div class="rounded-md bg-gray-200 p-5 transition-all" :class="{
          'filter blur-sm grayscale': element.loading
        }">
          <p class="italic text-gray-500 text-sm cursor-move">{{ element.partOfSpeech }}</p>
          <p v-if="!element.editing">{{ element.word?.word }}</p>
          <input v-if="element.editing" v-model="editingWord" @change="change(element)" ref="editingWordInput" />
          <div class="flex flex-row-reverse cursor-move pt-2">
            <button
                class="hover:bg-gray-300 text-red-500 rounded-full h-12 w-12 flex items-center justify-center cursor-pointer"
                @click="remove(element)"
            >
              <i class="material-icons">delete</i>
            </button>
            <button v-if="element.word?.word"
                title="Search google"
                class="hover:bg-gray-300 rounded-full h-12 w-12 flex items-center justify-center cursor-pointer"
                @click="search(element.word?.word)"
            >
              <i class="material-icons">manage_search</i>
            </button>
            <button v-if="element.word?.word && element.response?.data?.results?.[0]?.synonyms"
                title="Switch to a synonym"
                class="hover:bg-gray-300 rounded-full h-12 w-12 flex items-center justify-center cursor-pointer"
                @click="switchToSynonym(element.id)"
            >
              <i class="material-icons">unfold_more</i>
            </button>
            <button v-if="element.word?.word"
                title="Edit"
                class="hover:bg-gray-300 rounded-full h-12 w-12 flex items-center justify-center cursor-pointer"
                @click="edit(element)"
            >
              <i class="material-icons">edit</i>
            </button>
            <button v-if="element.word?.word"
                title="Retry"
                class="hover:bg-gray-300 rounded-full h-12 w-12 flex items-center justify-center cursor-pointer"
                @click="retry(element)"
            >
              <i class="material-icons">refresh</i>
            </button>
            <button v-if="!element.word?.word && element.partOfSpeech"
                title="Fill"
                class="hover:bg-gray-300 rounded-full h-12 w-12 flex items-center justify-center cursor-pointer"
                @click="retry(element)"
            >
              <i class="material-icons">navigate_next</i>
            </button>
          </div>
        </div>
      </template>
    </draggable>
    <div class="rounded-md bg-gray-200 p-5 my-2 flex flex-row items-center">
      <span v-if="wordsJoined">{{ `${wordsJoined[0]?.toUpperCase?.()}${wordsJoined.slice(1)}.` }}</span>
      <button
          v-if="wordsJoined"
          title="Copy to clipboard"
          class="hover:bg-gray-300 active:bg-gray-400 rounded-full h-12 w-12 flex items-center justify-center ml-auto"
          @click="copy"
      >
        <i class="material-icons">{{ copyIcon }}</i>
      </button>
    </div>
    <div class="rounded-md bg-gray-200 p-5 flex gap-2 my-2">
      <select v-model="selectedPart">
        <option>custom...</option>
        <option v-for="part of partsOfSpeech" :key="part">{{ part }}</option>
      </select>
      <input v-if="selectedPart == 'custom...'" v-model="customPart" ref="selectedPartInput" @change="add" />
      <button
          class="hover:bg-gray-300 active:bg-gray-400 rounded-full h-12 w-12 flex items-center justify-center"
          @click="add"
      >
        <i class="material-icons">add</i>
      </button>
    </div>
    <button @click="generate" class="fixed bottom-4 right-4 bg-green-700 hover:bg-green-500 text-white p-2 px-3 rounded-full m-auto flex gap-2 items-center justify-center cursor-pointer">
      <i class="material-icons">navigate_next</i>
      Generate
    </button>
  </div>
</template>

<script setup>
import { computed, reactive, ref } from "@vue/reactivity"
import { watch } from "@vue/runtime-core"
import axios from "axios"
import Draggable from 'vuedraggable'

const partsOfSpeech = ref([
  'noun',
  'pronoun',
  'verb',
  'adverb',
  'adjective',
  'preposition',
  'conjunction',
  'definite article'
])
const selectedPart = ref("noun")
const customPart = ref("")
const editingWord = ref("")
const lastWordSlotId = ref(7)
const wordSlots = reactive({
  1: { id: 1, partOfSpeech: 'noun',        word: {}, response: null, order: 1, loading: false },
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
const wordsJoined = computed(() => wordSlotsArray.value.map(slot => slot.word?.word).join(" "))
const drag = ref(false)
const selectedPartInput = ref(null)
watch(
  () => selectedPart.value,
  value => {
    if (value == 'custom...') {
      setTimeout(() => {
        selectedPartInput.value.focus()
        selectedPartInput.value.select()
      })
    }
  }
)
const editingWordInput = ref(null)

function add() {
  let isCustom = selectedPart.value == 'custom...'
  let selected = !isCustom ? selectedPart.value : customPart.value
  let nextId = lastWordSlotId.value++
  wordSlots[nextId] = {
    id: nextId,
    partOfSpeech: selected,
    word: {
      word: isCustom ? selected : null,
      partOfSpeech: isCustom ? selected : null,
    },
    response: !isCustom ? null : {
      data: {
        word: selected,
        results: [
          {
            partOfSpeech: selected,
          }
        ]
      }
    },
    order: nextId,
  }
}

function search(term) {
  window.open(`https://google.com/search?q=${term}`)
}

function edit(slot) {
  editingWord.value = slot.word?.word
  slot.editing = true
  setTimeout(() => {
    editingWordInput.value.focus()
    editingWordInput.value.select()
  })
}

function change(slot) {
  slot.word.word = editingWord.value
  editingWord.value = ""
  slot.editing = false
}

function switchToSynonym(slotId) {
  if (!wordSlots[slotId]) return
  let synonyms = wordSlots[slotId].response?.data?.results?.[0]?.synonyms
  wordSlots[slotId].word.word = synonyms[Math.floor(Math.random() * synonyms.length)]
}

async function retry(wordSlot) {
  wordSlots[wordSlot.id].loading = true
  wordSlots[wordSlot.id].response = await axios.request({
    method: "GET",
    url: "https://wordsapiv1.p.rapidapi.com/words/",
    headers: {
      "x-rapidapi-host": "wordsapiv1.p.rapidapi.com",
      "x-rapidapi-key": process.env.VUE_APP_WORDS_API_KEY,
    },
    params: {
      random: true,
      partOfSpeech: wordSlots[wordSlot.id].partOfSpeech,
      hasDetails: "definitions",
    },
  })

  let response = wordSlots[wordSlot.id].response
  let data = response?.data
  wordSlots[wordSlot.id].word = {
    word: data?.word,
    partOfSpeech: data?.results?.[0]?.partOfSpeech,
  }
  wordSlots[wordSlot.id].loading = false
}

function remove(slot) {
  delete wordSlots[slot.id]
}

async function generate() {
  const keys = Object.keys(wordSlots)

  for (let key of keys) {
    if (partsOfSpeech.value.includes(wordSlots[key].partOfSpeech)) {
      wordSlots[key].loading = true
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
      wordSlots[key].loading = false
    } else {
      wordSlots[key].response = {
        data: {
          word: wordSlots[key].partOfSpeech,
          partOfSpeech: ''
        }
      }
    }
    let response = wordSlots[key].response
    let data = response?.data
    wordSlots[key].word = {
      word: data?.word,
      partOfSpeech: data?.results?.[0]?.partOfSpeech,
    }
  }
}

const copyIcon = ref("content_copy")
async function copy() {
  await navigator.clipboard?.writeText?.(`${wordsJoined.value[0].toUpperCase()}${wordsJoined.value.slice(1)}.`)
  copyIcon.value = "check"
  setTimeout(() => copyIcon.value = "content_copy", 1500)
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

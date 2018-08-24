import sys
import json
import random
import copy
import re


'''
	This program mutates a normal personal name into a silly sounding version.
	(Ex: "Kevin Thompson" may become "Kifin Tompsan" or "Quevil Thankson")

	The program takes an input personal name given as space-delimited strings. It first runs checks to ensure the provided strings
are likely to be actual names (and not random letter combos or non-alpha chars), then uses the wordparts JSON to break
out the names into its significant letter combos (Ex: "Chundrick" -> ["ch", "u", "nd", "r", "i", "ck"]). The parts are then
mutated individually and joined back together to form the sillified name (Ex: ["ch", "u", "nd", "r", "i", "ck"] ->
["ch", "u", "mp", "l", "e", "rk"] -> "Chumplerk").
	The mutation is performed in a very dumb way but is sufficient to produce the desired result. The wordparts dictionary contains
'vowel' and 'consonant' dictionaries which contain the corresponding letter combos mapped to dicts with three keys: 'mutations' ->
a list of suitable letter combos to mutate to, 'adj_l' and 'adj_r' -> the numeric codes denoting which class of letter can be adjacent
this one on the left and right sides, respectively (See 'Wordparts Dictionary Excerpt' and 'Adjacency Rules Codes' below). These
hard-coded data ensure that the names are mutated in a sensible way by replacing the original parts with those having similar sounds
and by avoiding unusual or invalid letter combinations. Including many common 2-3 letter combinations in the wordparts dict helps
significantly to produce natural sound combinations. For example, if we treat the "nd" in "Chundrick" as the separate letters "n" and
"d", we may get back the mutations "m" and "t." These mutations are fine on their own, but after joining back together they would form
the unnatural combination "mt", producing the awkward name "Chumtlerk" instead of "Chumplerk."
	Randomized shuffling of possible mutation targets and occassional "two-hop" mutations (mutating an already mutated part) are done
to give results a higher rate of variation. However, the algorithm also ensures that not every word part gets mutated so that the
result is still recognizable as a variation of the original name and not something entirely different.


Wordparts Dictionary Excerpt:
{
	"vowel": {
		"a": {"mutations": ["a", "o", "u"], "adj_l": 3, "adj_r": 3},
		"ai": {"mutations": ["a", "ai", "e", "ei", "y"], "adj_l": 1, "adj_r": 1},
		...
	},
	"consonant": {
		"b": {"mutations": ["d", "p"], "adj_l": 3, "adj_r": 3},
		"bb": {"mutations": ["b", "d", "dd", "p", "pp"], "adj_l": 30, "adj_r": 3},
		...
	}
}

Adjacency Rules Codes:
	0 - start/end only
	1 - consonant only
	2 - vowel only
	3 - any
	10 - consonant only, cannot be at start/end
	20 - vowel only, cannot be at start/end
	30 - any, cannot be at start/end
'''


# This wordParts dictionary is both how the program will identify discrete consonant and vowel strings and how it will choose a suitable mutation.
with open('wordparts.json') as data_file:
    wordParts = json.load(data_file)


def isValidName(nameStr):
	return re.match(r"^[a-zA-Z/' ]+$", nameStr)


def capitalizeName(name):
	capName = ''
	for n in name.split():
		if n.startswith('mc') or n.startswith('mac'):
			n = (n.split('c', 1)[0]).capitalize()+'c'+(n.split('c', 1)[1]).capitalize()
		else:
			n = n.capitalize()
		capName += n + ' '
	return capName.rstrip(' ')


def enforceAdjRules(reqLeftAdj, reqRightAdj, item):
	leftAdj = item['adj_l']
	rightAdj = item['adj_r']
	leftAllowsAny = leftAdj == 3 or leftAdj == 30
	rightAllowsAny = rightAdj == 3 or rightAdj == 30
	if (reqLeftAdj and reqRightAdj):
		return (leftAdj == reqLeftAdj or leftAdj == reqLeftAdj*10 or leftAllowsAny) and (rightAdj == reqRightAdj or rightAdj == reqRightAdj*10 or rightAllowsAny)
	elif (reqLeftAdj and not reqRightAdj):
		return (leftAdj == reqLeftAdj or leftAdj == reqLeftAdj*10 or leftAdj == 3 or leftAdj == 30) and rightAdj <= 3
	elif (not reqLeftAdj and reqRightAdj):
		return (rightAdj == reqRightAdj or rightAdj == reqRightAdj*10 or rightAllowsAny) and leftAdj <= 3
	else:
		return True


def filterPartsDict(p, leftPartType, rightPartType, partType):
	passedPart = wordParts[partType][p]
	partNum = 1 if partType == 'consonant' else 2
	leftPartNum = 0
	rightPartNum = 0
	if leftPartType:
		leftPartNum = 1 if leftPartType == 'consonant' else 2
	if rightPartType:
		rightPartNum = 1 if rightPartType == 'consonant' else 2
	return {k:v for (k,v) in copy.deepcopy(wordParts[partType]).items() if enforceAdjRules(leftPartNum, rightPartNum, v)}


def mutateWordPart(p, leftPartType, rightPartType, partType):
	if p == 'mc' or p == 'mac': return p
	if p == 'e' and rightPartType == 0: return p
	filteredParts = filterPartsDict(p, leftPartType, rightPartType, partType);
	partsList = list(filteredParts)
	random.shuffle(filteredParts[p]['mutations'])
	random.shuffle(partsList)
	randomPassedPartChange = filteredParts[p]['mutations'].pop()
	while randomPassedPartChange not in partsList:
		randomPassedPartChange = filteredParts[p]['mutations'].pop()
	randomOtherPart = partsList[0]
	random.shuffle(filteredParts[randomOtherPart]['mutations'])
	print(randomOtherPart)
	randomOtherPartChange = filteredParts[randomOtherPart]['mutations'].pop()
	while randomOtherPartChange not in partsList:
		randomOtherPartChange = filteredParts[randomOtherPart]['mutations'].pop()
	randNum = random.randint(0,10)
	return randomPassedPartChange if randNum > 3 else randomOtherPartChange


def mutateWords(wordsDict):
	wordStr = ''
	for word in wordsDict:
		chosenIndexes = random.sample(range(len(wordsDict[word])), round(len(wordsDict[word])*0.4))
		for i in range(len(wordsDict[word])):
			part = wordsDict[word][i]
			leftPartType = 0 if i == 0 else wordsDict[word][i - 1]['type']
			rightPartType = 0 if i == len(wordsDict[word]) - 1 else wordsDict[word][i + 1]['type']
			if i in chosenIndexes:
				mutated = mutateWordPart(part['part'], leftPartType, rightPartType, part['type'])
				wordStr += mutated
			else:
				wordStr += part['part']
		wordStr += ' '
	return wordStr.rstrip(' ')


def identifyWordParts(words):
	wordBreakdowns = {}
	wordsList = words.split(' ')
	for word in wordsList:
		wordBreakdowns[word] = []
		wordLen = len(word)
		start = 0
		while wordLen >= 0:
			wordChunk = word[start:wordLen].lower()
			middle = start != 0 and wordLen < len(word)
			vowelList = [part for part in list(wordParts['vowel']) if (wordParts['vowel'][part]['adj_l'] <= 3 and start == 0) or (wordParts['vowel'][part]['adj_l'] > 0 and wordParts['vowel'][part]['adj_r'] > 0 and middle) or (wordParts['vowel'][part]['adj_r'] <= 3 and wordLen == len(word))]
			consList = [part for part in list(wordParts['consonant']) if (wordParts['consonant'][part]['adj_l'] <= 3 and start == 0) or (wordParts['consonant'][part]['adj_l'] > 0 and wordParts['consonant'][part]['adj_r'] > 0 and middle) or (wordParts['consonant'][part]['adj_r'] <= 3 and wordLen == len(word))]
			if wordChunk in vowelList:
				identifiedPart = {'type': 'vowel', 'start': start == 0, 'end': wordLen == len(word), 'part': wordChunk}
				wordBreakdowns[word].append(identifiedPart)
				start = wordLen
				wordLen = len(word)
				continue
			elif wordChunk in consList:
				identifiedPart = {'type': 'consonant', 'start': start == 0, 'end': wordLen == len(word), 'part': wordChunk}
				wordBreakdowns[word].append(identifiedPart)
				start = wordLen
				wordLen = len(word)
				continue
			wordLen -= 1
	# print(list(map(lambda o: [x['part'] for x in o], wordBreakdowns.values())))
	return wordBreakdowns


if __name__ == '__main__':
	name = ''
	if len(sys.argv) == 0:
		name = input("Please provide a space-delimited name: ")
	else:
		for i in range(1, len(sys.argv)):
			name += sys.argv[i] + ' '

	while not isValidName(name):
		print("Names may only contain letters and apostrophes.")
		name = input("Please provide a space-delimited name: ")

	identified = identifyWordParts(name)
	mutated = capitalizeName(mutateWords(identified))
	print(mutated)

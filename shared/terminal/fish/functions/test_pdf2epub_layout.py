#!/usr/bin/env python3
"""Reading-order tests for two-column PDF reconstruction."""

from __future__ import annotations

import unittest

from pdf2epub_layout import (
    Block,
    Page,
    column_cut,
    document_has_columns,
    join_lines,
    pages_to_html,
    parse_bbox_layout,
    reading_order,
)


def block(x0: float, y0: float, x1: float, y1: float, text: str) -> Block:
    return Block(x0=x0, y0=y0, x1=x1, y1=y1, lines=(text,))


def page_of(*blocks: Block, width: float = 561.0, height: float = 842.0) -> Page:
    return Page(width=width, height=height, blocks=blocks)


# Geometry from How-To-Heal-An-Anxious-Attachment-Style.pdf page 5.
ANXIOUS_INTRO = page_of(
    block(97, 90, 464, 149, "HOW TO HEAL AN ANXIOUS ATTACHMENT STYLE"),
    block(99, 189, 462, 222, "“The first step towards getting somewhere is to decide you’re not going to stay where you are.”"),
    block(56, 283, 265, 325, "First of all, welcome. Looks like you just became aware of your anxious attachment style and you're ready for a change."),
    block(291, 283, 484, 310, "You might be wondering, why shadow work? Well, the answer is simple."),
    block(291, 328, 502, 401, "It's a powerful psychological tool that helps you to access the hidden parts of your personality."),
    block(56, 343, 259, 370, "You've basically already completed step one; awareness. So, congrats on that."),
    block(56, 389, 269, 431, "How to Heal an Anxious Attachment Style is here to help you on the next part of your journey."),
    block(291, 419, 504, 461, "We've curated a series of prompts that will make you reflect on a level so deeply, that you learn new things about yourself."),
    block(56, 449, 271, 477, "You've probably never tried a journal quite like this before, so here's what to expect."),
    block(291, 480, 498, 537, "Most importantly, we’ll equip you with practical tools and techniques to help you self-regulate."),
    block(56, 495, 262, 613, "Together, we'll delve into the origins of your anxious attachment style."),
    block(291, 555, 494, 613, "Before we get started, take a moment to think about what you hope to achieve throughout this journey."),
    block(56, 631, 272, 674, "Think of this journal like a trusty friend who’s great at listening."),
    block(291, 631, 499, 658, "Consider this your personal safe space to be honest and real with yourself."),
    block(291, 677, 501, 704, "Cool, now that you've done that, ready to get started?"),
    block(275, 785, 281, 797, "5"),
)


TRIGGER_WARNING = page_of(
    block(190, 285, 371, 310, "TRIGGER WARNING"),
    block(79, 336, 483, 370, "This journal engages with deep and often challenging aspects of personal development."),
    block(79, 380, 482, 414, "Please approach the exercises with care."),
)


TOC = page_of(
    block(169, 91, 392, 120, "THE JOURNEY"),
    block(77, 218, 171, 232, "INTRODUCTION"),
    block(472, 217, 478, 229, "4"),
    block(77, 248, 412, 262, "UNDERSTANDING YOUR ANXIOUS ATTACHMENT STYLE"),
    block(472, 247, 478, 259, "6"),
    block(77, 279, 340, 293, "THE POWER OF YOUR SUBCONSCIOUS MIND"),
    block(469, 278, 482, 290, "23"),
    block(77, 310, 306, 324, "TECHNIQUES TO REWIRE YOUR BRAIN"),
    block(469, 308, 482, 320, "35"),
)


IF_THEN = page_of(
    block(71, 92, 494, 119, "DEALING WITH ANXIOUS TRIGGERS"),
    block(56, 149, 504, 206, "You’ve explored what triggers you; now it’s time to practice responding differently."),
    block(56, 225, 69, 241, "IF"),
    block(257, 225, 297, 241, "THEN"),
    block(56, 262, 223, 274, "If I get left on read for ___ hours"),
    block(251, 261, 507, 288, "then I will wait ___ minutes, take a breath, and do _________________ before deciding to reach out."),
    block(56, 307, 191, 334, "If I start over-analyzing or replaying a small moment"),
    block(249, 307, 492, 334, "then I will catch the story I’m telling myself and ask once for clarification if needed."),
    block(54, 354, 188, 366, "If I feel them pulling away"),
    block(249, 354, 472, 381, "then I will express my needs and come to an agreement"),
    block(54, 398, 210, 425, "If I feel too much after sharing something vulnerable"),
    block(248, 400, 502, 427, "then I will remind myself that expressing my needs is okay."),
    block(56, 449, 210, 476, "If I begin spiraling when plans change or feel uncertain,"),
    block(251, 448, 506, 490, "then I will remind myself that change isn’t danger."),
    block(54, 510, 219, 537, "If I feel triggered by something I saw on social media"),
    block(249, 509, 494, 551, "then I will pause before reacting."),
    block(54, 571, 202, 583, "If I start to spiral when alone"),
    block(249, 570, 504, 598, "then I will return to my body."),
    block(272, 785, 287, 797, "121"),
)


QUOTE_XML = """\
<html xmlns="http://www.w3.org/1999/xhtml">
<body><doc>
<page width="561" height="842">
  <flow>
    <block xMin="99" yMin="189" xMax="462" yMax="222">
      <line xMin="99" yMin="189" xMax="462" yMax="206">
        <word xMin="99" yMin="189" xMax="131" yMax="206">The</word>
        <word xMin="134" yMin="189" xMax="161" yMax="206">first</word>
        <word xMin="164" yMin="189" xMax="193" yMax="206">step</word>
        <word xMin="197" yMin="189" xMax="251" yMax="206">towards</word>
        <word xMin="254" yMin="189" xMax="301" yMax="206">getting</word>
        <word xMin="305" yMin="189" xMax="382" yMax="206">somewhere</word>
        <word xMin="386" yMin="189" xMax="397" yMax="206">is</word>
        <word xMin="401" yMin="189" xMax="414" yMax="206">to</word>
        <word xMin="418" yMin="189" xMax="462" yMax="206">decide</word>
      </line>
    </block>
    <block xMin="56" yMin="283" xMax="265" yMax="325">
      <line xMin="56" yMin="283" xMax="260" yMax="294">
        <word xMin="56" yMin="283" xMax="80" yMax="294">First</word>
        <word xMin="83" yMin="283" xMax="110" yMax="294">of</word>
        <word xMin="113" yMin="283" xMax="140" yMax="294">all,</word>
        <word xMin="143" yMin="283" xMax="200" yMax="294">welcome.</word>
      </line>
    </block>
    <block xMin="291" yMin="283" xMax="484" yMax="310">
      <line xMin="291" yMin="283" xMax="480" yMax="294">
        <word xMin="291" yMin="283" xMax="320" yMax="294">You</word>
        <word xMin="323" yMin="283" xMax="360" yMax="294">might</word>
        <word xMin="363" yMin="283" xMax="385" yMax="294">be</word>
        <word xMin="388" yMin="283" xMax="460" yMax="294">wondering</word>
      </line>
    </block>
    <block xMin="56" yMin="343" xMax="259" yMax="370">
      <line xMin="56" yMin="343" xMax="250" yMax="355">
        <word xMin="56" yMin="343" xMax="250" yMax="355">Left column continues with enough words to count as a real paragraph of body text.</word>
      </line>
    </block>
    <block xMin="291" yMin="328" xMax="502" yMax="401">
      <line xMin="291" yMin="328" xMax="490" yMax="340">
        <word xMin="291" yMin="328" xMax="490" yMax="340">Right column continues with enough words to count as a real paragraph of body text too.</word>
      </line>
    </block>
  </flow>
</page>
</doc></body></html>
"""


class JoinLinesTests(unittest.TestCase):
    def test_hyphen_at_line_end_rejoins_the_word(self) -> None:
        self.assertEqual(join_lines(["be-", "came"]), "became")

    def test_ordinary_lines_are_spaced(self) -> None:
        self.assertEqual(join_lines(["First of all,", "welcome."]), "First of all, welcome.")
        self.assertEqual(join_lines(["completed step", "one; awareness."]), "completed step one; awareness.")


class AnxiousIntroTests(unittest.TestCase):
    def test_detects_two_columns(self) -> None:
        self.assertIsNotNone(column_cut(ANXIOUS_INTRO))

    def test_reads_left_column_before_right(self) -> None:
        texts = [item.text for item in reading_order(ANXIOUS_INTRO)]
        left = "First of all, welcome"
        right = "You might be wondering, why shadow work"
        self.assertLess(texts.index(next(t for t in texts if t.startswith(left))), texts.index(next(t for t in texts if t.startswith(right))))
        self.assertLess(
            texts.index(next(t for t in texts if t.startswith("Think of this journal"))),
            texts.index(next(t for t in texts if t.startswith("You might be wondering"))),
        )

    def test_title_and_quote_stay_above_the_columns(self) -> None:
        texts = [item.text for item in reading_order(ANXIOUS_INTRO)]
        self.assertEqual(texts[0], "HOW TO HEAL AN ANXIOUS ATTACHMENT STYLE")
        self.assertTrue(texts[1].startswith("“The first step towards getting somewhere"))

    def test_drops_the_page_number(self) -> None:
        texts = [item.text for item in reading_order(ANXIOUS_INTRO)]
        self.assertNotIn("5", texts)

    def test_quote_keeps_spaces_between_words(self) -> None:
        quote = reading_order(ANXIOUS_INTRO)[1].text
        self.assertIn("The first step towards getting somewhere", quote)
        self.assertNotIn("Thefirststep", quote)


class SingleColumnTests(unittest.TestCase):
    def test_full_width_page_is_not_two_column(self) -> None:
        self.assertIsNone(column_cut(TRIGGER_WARNING))

    def test_toc_page_numbers_are_not_a_column(self) -> None:
        self.assertIsNone(column_cut(TOC))

    def test_single_column_keeps_top_to_bottom_order(self) -> None:
        texts = [item.text for item in reading_order(TRIGGER_WARNING)]
        self.assertEqual(texts[0], "TRIGGER WARNING")
        self.assertTrue(texts[1].startswith("This journal engages"))


class TableTests(unittest.TestCase):
    def test_if_then_rows_read_across(self) -> None:
        texts = [item.text for item in reading_order(IF_THEN)]
        if_line = next(index for index, text in enumerate(texts) if text.startswith("If I get left on read"))
        then_line = next(index for index, text in enumerate(texts) if text.startswith("then I will wait"))
        next_if = next(index for index, text in enumerate(texts) if text.startswith("If I start over-analyzing"))
        self.assertEqual(then_line, if_line + 1)
        self.assertEqual(next_if, then_line + 1)


class ParseTests(unittest.TestCase):
    def test_bbox_words_are_joined_with_spaces(self) -> None:
        pages = parse_bbox_layout(QUOTE_XML)
        self.assertTrue(document_has_columns(pages))
        texts = [item.text for item in reading_order(pages[0])]
        self.assertEqual(texts[0], "The first step towards getting somewhere is to decide")
        self.assertNotIn("Thefirststep", "".join(texts))

    def test_strips_illegal_xml_control_characters(self) -> None:
        xml = """\
<html xmlns="http://www.w3.org/1999/xhtml">
<body><doc>
<page width="561" height="842">
  <block xMin="99" yMin="189" xMax="462" yMax="222">
    <line xMin="99" yMin="189" xMax="462" yMax="206">
      <word xMin="99" yMin="189" xMax="131" yMax="206">mu\x1dsic</word>
      <word xMin="134" yMin="189" xMax="161" yMax="206">\x1d</word>
      <word xMin="164" yMin="189" xMax="193" yMax="206">notation</word>
    </line>
  </block>
</page>
</doc></body></html>
"""
        pages = parse_bbox_layout(xml)
        self.assertEqual(len(pages), 1)
        self.assertEqual(pages[0].blocks[0].text, "music notation")

    def test_html_escapes_and_contains_left_column_first(self) -> None:
        markup = pages_to_html([ANXIOUS_INTRO], "anxious")
        self.assertIn("<title>anxious</title>", markup)
        first = markup.find("First of all, welcome")
        shadow = markup.find("You might be wondering, why shadow work")
        self.assertGreater(first, 0)
        self.assertGreater(shadow, first)


if __name__ == "__main__":
    unittest.main()

---
author: Xavier Salvador
title: 15.- Internal Aspect of JUnit
date: 2025-02-23
page_order: 15
categories: [ "clean_code" ]
tags: [ "clean code" ]
layout: post
excerpt_separator: <!--more-->
---

<!--more-->

# Internal Aspect of JUnit

This short consultancy-style guide covers the internal aspects of writing good unit tests with JUnit (focused on JUnit 5, but the principles apply broadly). It explains how to structure tests, use JUnit features effectively, avoid common test smells, and keep tests fast, readable and reliable.

## What this note covers

- JUnit anatomy and lifecycle annotations
- Test structure and the Arrange-Act-Assert pattern
- Fixtures, builders and avoiding setup bloat
- Assertions and failure messages
- Parameterized tests and nested contexts
- Handling exceptions and timeouts
- Flakiness, isolation, and speed
- Quick checklist for a test-quality review

## JUnit anatomy (the basics)

Key JUnit 5 annotations and their purpose:

- @Test — marks a test method.
- @BeforeEach / @AfterEach — run before/after each test (per-test fixtures).
- @BeforeAll / @AfterAll — run once for the test class (static by default).
- @Nested — groups related tests in a nested class to express context.
- @DisplayName — human-friendly test name for reports.
- @ParameterizedTest with @ValueSource / @CsvSource / @MethodSource — run the same test with multiple inputs.
- @RepeatedTest — repeat a test multiple times (useful for detecting nondeterminism).

Use these to express intent, not to hide complexity. Prefer small, focused tests that need minimal fixture setup.

## Test structure: arrange-act-assert (AAA)

Every test should follow AAA explicitly:

1. Arrange — create test data and mocks/stubs. Keep builders or factories outside the test body when they obscure intent.
2. Act — execute the single behavior being tested.
3. Assert — verify the observable results (return values, state changes, interactions).

Keep the Act section to one line when possible. If you need multiple actions, it often means the test is doing too much.

## Fixtures and builders: keep setup readable

- Avoid large @BeforeEach methods that prepare a complex world for many unrelated tests. They hide intent and make tests brittle.
- Prefer local setup in the test when the data is specific to that scenario.
- Use test data builders (a simple fluent API) to construct domain objects; put them in test helpers so tests remain expressive: order = OrderBuilder.aOrder().withItem(...).build();
- Use named factory methods for common fixtures (givenActiveCustomer(), anEmptyCart()). Naming matters more than clever reuse.

## Assertions and failure messages

- Use assertion libraries (JUnit's Assertions, AssertJ, Hamcrest) to express intent clearly.
- Prefer expressive assertions that read like documentation: assertThat(invoice.total()).isEqualTo(Money.of(100));
- Include messages or use fluent libraries to show expected vs actual when default messages are insufficient.
- Test one logical assertion per test. Multiple verifications are OK if they describe the same behavior (e.g., result and domain events emitted).

## Parameterized tests and contexts

- Parameterized tests reduce duplication for input variations. Use them for correctness across many inputs.
- Don't use parameterized tests to test many orthogonal behaviors; keep them focused on the same assertion applied to different inputs.
- Use @Nested classes to express context and keep test names concise: the outer class names the behavior, the nested class names the scenario.

## Handling exceptions and timeouts

- Use assertThrows to verify exceptions and to capture the thrown instance for further assertions.
- Prefer explicit timeouts only when a method is expected to be long-running. For unstable external calls, isolate them behind test doubles and test timeout behavior at the unit level through mocks.

Example:

- assertThrows(InsufficientStockException.class, () -> inventoryService.reserve(item, qty));

## Mocks, stubs and test doubles

- Use mocks to assert interactions with collaborators, but avoid over-mocking: tests that assert every interaction are brittle and couple to implementation.
- Prefer state-based assertions when they fully describe the behavior. Use interaction-based assertions when behavior is about the message sent.
- Keep mocking frameworks as a tool, not the test structure. Encapsulate mock setup in helper methods with descriptive names (givenPaymentWillSucceed()).

## Flakiness, isolation and speed

- Flaky tests erode confidence. Common causes: reliance on wall-clock time, shared mutable state, network or filesystem, and ordering dependencies.
- Make tests deterministic: seed randomized inputs explicitly, avoid sleeping in tests, and use virtual clocks or test doubles for time-dependent logic.
- Keep unit tests fast (<100ms ideally per test) so they run frequently. Use an integration test suite for slower end-to-end checks.
- Run tests in parallel only when tests are fully isolated and thread-safe. Prefer CI-level parallelism after local reliability is achieved.

## Naming tests well

- Test names are documentation. Use descriptive names that include expected behavior and scenario: shouldReturnInvoiceWhenOrderIsValid.
- For parameterized tests use the display name pattern to include input values in reports.
- Prefer human readable names with underscores or DisplayName annotations if that improves clarity.

## Quick examples (JUnit 5 style)

1) Simple AAA test:

- @Test
  void shouldCalculateTotalForSingleItem() {
    // Arrange
    var order = OrderBuilder.aOrder().withItem("widget", 2, Money.of(10)).build();

    // Act
    var invoice = orderService.process(order);

    // Assert
    assertThat(invoice.total()).isEqualTo(Money.of(20));
  }

2) Exception test:

- @Test
  void shouldThrowWhenStockUnavailable() {
    // Arrange
    givenInventoryHas("widget", 1);
    var order = OrderBuilder.aOrder().withItem("widget", 2, Money.of(10)).build();

    // Act & Assert
    assertThrows(InsufficientStockException.class, () -> orderService.process(order));
  }

3) Parameterized example:

- @ParameterizedTest
  @CsvSource({"1, true", "0, false"})
  void shouldMarkAsAvailableBasedOnStock(int stock, boolean expectedAvailable) {
    var item = new Item("widget", stock);
    assertThat(item.isAvailable()).isEqualTo(expectedAvailable);
  }

## Short checklist for a quick test review (consultancy)

- [ ] Does each test follow Arrange-Act-Assert clearly?
- [ ] Are tests small and focused on one behavior?
- [ ] Are fixtures minimal and descriptive (no huge @BeforeEach)?
- [ ] Are assertions expressive and helpful on failure?
- [ ] Is the use of mocks justified and not over-specified?
- [ ] Are tests deterministic and fast?
- [ ] Are nested contexts or parameterized tests used where they improve clarity?
- [ ] Do test names document the behavior and expected outcome?

## Common test smells to watch for

- Long @BeforeEach with dozens of setup lines.
- Tests that require other tests to run before them (order dependencies).
- Frequent use of sleep or time-based waits.
- Assertion explosion: a single test asserting many unrelated things.
- Overuse of mocks to verify internal implementation details.

## Recommended fixes and quick wins

- Extract builders or factory methods for complex fixtures and keep names expressive.
- Convert fragile integration-style unit tests into true unit tests by mocking external services and verifying behavior.
- Replace sleeps with virtual clocks or retry helpers with clear timeouts in integration tests.
- Add one or two focused integration tests and keep the majority of checks at the unit level.

## When to reach for JUnit features vs. custom helpers

Use built-in JUnit features for lifecycle and parameterization. Add lightweight custom test helpers (builders, a few factory methods, and descriptive mock setup functions). Avoid heavy test frameworks unless you need the specific capability (e.g., property-based testing or advanced mocking scenarios).

## Closing recommendation

Treat test code with the same discipline as production code: prefer clarity, small functions (test methods), good names, and explicit contracts. Tests are the most important documentation for business behavior — keep them fast and trustworthy so they guide future refactors safely.

## Java + JUnit 5 examples (using AssertJ)

Below are concrete Java examples that show how the previously described principles map to real JUnit 5 + AssertJ tests. These are concise, idiomatic patterns you can copy into your test suite.

1) Simple AAA test with AssertJ

```java
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;

class OrderServiceTest {

    @Test
    void shouldCalculateTotalForSingleItem() {
        // Arrange
        Order order = OrderBuilder.anOrder()
            .withItem("widget", 2, Money.of(10))
            .build();
        OrderService service = new OrderService(/* collaborators */);

        // Act
        Invoice invoice = service.process(order);

        // Assert
        assertThat(invoice.getTotal()).isEqualTo(Money.of(20));
    }
}
```

2) Exception testing with AssertJ (clear and chainable)

```java
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class OrderServiceExceptionTest {

    @Test
    void shouldThrowWhenStockUnavailable() {
        // Arrange
        givenInventoryHas("widget", 1);
        Order order = OrderBuilder.anOrder().withItem("widget", 2, Money.of(10)).build();
        OrderService service = new OrderService(/* deps */);

        // Act & Assert
        assertThatThrownBy(() -> service.process(order))
            .isInstanceOf(InsufficientStockException.class)
            .hasMessageContaining("widget");
    }
}
```

3) Parameterized test example

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import static org.assertj.core.api.Assertions.assertThat;

class ItemTest {

    @ParameterizedTest
    @CsvSource({"1,true", "0,false"})
    void shouldMarkAsAvailableBasedOnStock(int stock, boolean expectedAvailable) {
        var item = new Item("widget", stock);
        assertThat(item.isAvailable()).isEqualTo(expectedAvailable);
    }
}
```

4) Mock-based interaction test (Mockito + AssertJ)

```java
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class OrderServiceInteractionTest {

    InventoryService inventory;
    PaymentService payment;
    OrderService service;

    @BeforeEach
    void setUp() {
        inventory = mock(InventoryService.class);
        payment = mock(PaymentService.class);
        service = new OrderService(inventory, payment);
    }

    @Test
    void shouldReserveInventoryAndChargePayment() {
        // Arrange
        Order order = OrderBuilder.anOrder().withItem("widget", 1, Money.of(10)).build();
        when(inventory.reserve(order)).thenReturn(true);
        when(payment.charge(any(), any())).thenReturn(PaymentResult.success());

        // Act
        Invoice invoice = service.process(order);

        // Assert
        assertThat(invoice).isNotNull();
        verify(inventory).reserve(order);
        verify(payment).charge(eq(order.getPaymentInfo()), any());
    }
}
```

5) Nested context example (express scenarios clearly)

```java
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;

class ShoppingCartTest {

    @Nested
    class WhenCartIsEmpty {
        @Test
        void shouldBeEmpty() {
            var cart = new ShoppingCart();
            assertThat(cart.isEmpty()).isTrue();
        }
    }

    @Nested
    class WhenCartHasItems {
        @Test
        void shouldComputeTotal() {
            var cart = new ShoppingCart();
            cart.add(new Item("x", 2, Money.of(5)));
            assertThat(cart.total()).isEqualTo(Money.of(10));
        }
    }
}
```

Small notes:
- Use AssertJ's rich API (assertThatThrownBy, extracting, tuple, etc.) to make assertions self-explanatory.
- Keep mocking simple: prefer when(...).thenReturn(...) and verify(...) only for behavior that matters to the contract.
- Use builders (OrderBuilder, Item builder) in test sources to keep Arrange sections readable.

If you want, I can review one or two of your test classes and create a PR that refactors fixtures into builders, improves test names, and converts brittle tests into robust unit tests. Point me to the test files you want improved.

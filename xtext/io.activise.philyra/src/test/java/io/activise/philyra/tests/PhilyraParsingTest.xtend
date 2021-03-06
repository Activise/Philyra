/*
 * generated by Xtext 2.23.0
 */
package io.activise.philyra.tests

import com.google.inject.Inject
import io.activise.philyra.philyra.ECompilationUnit
import io.activise.philyra.philyra.EEntity
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.junit.Assert.*
import org.eclipse.xtext.EcoreUtil2

@ExtendWith(InjectionExtension)
@InjectWith(PhilyraInjectorProvider)
class PhilyraParsingTest {
	@Inject
	extension ParseHelper<ECompilationUnit> parseHelper

	@Inject
	extension ValidationTestHelper

	@Inject
	extension IQualifiedNameProvider

	@Test
	def void loadModel() {
		val compilationUnit = createExampleCompilationUnit()

		compilationUnit.getAllContentsOfType(EEntity).forEach [ e |
			println('''«e.name» + «e.tableName»''')
			println(e.fullyQualifiedName)
			println("+++")
			e.attributes.forEach [
				println('''«it.name» + «it.type.name» + «it.opposite?.name»''')
			]
			println("----------------------------")
		]

		compilationUnit.validate.forEach[println(message)];

		println(compilationUnit?.eResource?.errors)
	}

	@Test
	def void Should_NotContainErrors_When_Parsed() {
		createExampleCompilationUnit().assertNoErrors
	}

	@Test
	def void Should_ContainValidInformation_When_Parsed() {
		val it = createExampleCompilationUnit()
		assertType("String", "java.lang.String")
		assertType("Date", "java.time.LocalDate")
		assertType("DateTime", "java.time.LocalDateTime")

		assertEntity("Order", "orders")
		assertEntity("OrderEntry", "order_entries")

		assertAttribute("Order", "orderEntries", "OrderEntry", "order", "Order")
		assertAttribute("OrderEntry", "order", "Order")
	}

	def void assertType(ECompilationUnit compilationUnit, String name, String target) {
		compilationUnit.types.exists[it.name.equals(name) && it.target.equals(target)].assertTrue
	}

	def void assertEntity(ECompilationUnit compilationUnit, String entityName, String tableName) {
		compilationUnit.entities.exists[it.name.equals(entityName) && it.tableName.equals(tableName)].assertTrue
	}


	def void assertAttribute(ECompilationUnit compilationUnit, String entityName, String attributeName, String typeName) {
		val it = compilationUnit.entities.filter[name.equals(entityName)].findFirst[true]
		attributes.exists[name.equals(attributeName) && type.name.equals(typeName)].assertTrue
	}

	def void assertAttribute(ECompilationUnit compilationUnit, String entityName, String attributeName, String typeName,
		String oppositeName, String oppositeType) {
		val it = compilationUnit.entities.filter[name.equals(entityName)].findFirst[true]
		attributes.exists [
			name.equals(attributeName) && type.name.equals(typeName) && opposite.name.equals(oppositeName) &&
				opposite.type.name.equals(oppositeType)
		].assertTrue
	}

	def createExampleCompilationUnit() {
		'''
			import io.activise.customer.*

			type String to "java.lang.String"
			type Date to "java.time.LocalDate"
			type DateTime to "java.time.LocalDateTime"

			entity Order(orders) {
				customer: Customer;
				orderEntries: OrderEntry[0..n] from order;
			}

			entity OrderEntry(order_entries) {
				order: Order;
			}

			package io.activise.customer {
				entity Customer {
					id name: String;
				}
			}
		'''.parse()
	}
}

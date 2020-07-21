/*
 * Copyright (c) 2013-2014 Wind River Systems, Inc.
 * Copyright (c) 2017-2019 Nordic Semiconductor ASA.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @file
 * @brief Fault handlers for ARM Cortex-M
 *
 * Fault handlers for ARM Cortex-M processors.
 */

#include <toolchain.h>
#include <linker/sections.h>

_ASM_FILE_PROLOGUE

GTEXT(z_arm_fault)

GTEXT(z_arm_hard_fault)
#if defined(CONFIG_ARMV6_M_ARMV8_M_BASELINE)
/* HardFault is used for all fault conditions on ARMv6-M. */
#elif defined(CONFIG_ARMV7_M_ARMV8_M_MAINLINE)
GTEXT(z_arm_mpu_fault)
GTEXT(z_arm_bus_fault)
GTEXT(z_arm_usage_fault)
#if defined(CONFIG_ARM_SECURE_FIRMWARE)
GTEXT(z_arm_secure_fault)
#endif /* CONFIG_ARM_SECURE_FIRMWARE*/
GTEXT(z_arm_debug_monitor)
#else
#error Unknown ARM architecture
#endif /* CONFIG_ARMV6_M_ARMV8_M_BASELINE */
GTEXT(z_arm_exc_spurious)

/**
 *
 * @brief Fault handler installed in the fault vectors
 *
 * Entry point for the HardFault, MemManageFault, BusFault, UsageFault,
 * SecureFault and Debug Monitor exceptions.
 *
 * The function supplies the values of
 * - the MSP
 * - the PSP
 * - Register state not preserved by hardware (r4-r11 & EXC_RETURN)
 * as parameters to the z_arm_fault() C function that will perform the
 * rest of the fault handling:
 *    (i.e. z_arm_fault(MSP, PSP, struct __callee_saved_esf *)).
 * Provides these symbols:
 *
 *   z_arm_hard_fault
 *   z_arm_mpu_fault
 *   z_arm_bus_fault
 *   z_arm_usage_fault
 *   z_arm_secure_fault
 *   z_arm_debug_monitor
 *   z_arm_exc_spurious
 */

SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_hard_fault)
#if defined(CONFIG_ARMV6_M_ARMV8_M_BASELINE)
/* HardFault is used for all fault conditions on ARMv6-M. */
#elif defined(CONFIG_ARMV7_M_ARMV8_M_MAINLINE)
SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_mpu_fault)
SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_bus_fault)
SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_usage_fault)
#if defined(CONFIG_ARM_SECURE_FIRMWARE)
SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_secure_fault)
#endif /* CONFIG_ARM_SECURE_FIRMWARE */
SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_debug_monitor)
#else
#error Unknown ARM architecture
#endif /* CONFIG_ARMV6_M_ARMV8_M_BASELINE */
SECTION_SUBSEC_FUNC(TEXT,__fault,z_arm_exc_spurious)

#if defined(CONFIG_ARMV6_M_ARMV8_M_BASELINE)
	/* Build __callee_saved_esf */
	mov r3, r11
	mov r2, r10
	mov r1, r9
	mov r0, r8
	push {r0-r3, lr}
	push {r3-r7}

	/* Recover MSP at exception entry. */
	mrs r0, MSP
	adds r0, r0, #40

	mrs r1, PSP
#else
	mrs r0, MSP
	mrs r1, PSP
	/* Build __callee_saved_esf */
	push {r3-r11, lr}
#endif

	/**
	* Recover pointer to __callee_saved_esf and pass set it as our
	* 3rd argument to z_arm_fault(). Note we pushed one extra register, r3,
	* to double-word align the stack to satisfy ABI requirements so we
	* need to add 4 to the current sp to get the struct start address.
	*/
	mov r2, sp
	adds r2, r2, #4

	bl z_arm_fault


#if defined(CONFIG_ARMV6_M_ARMV8_M_BASELINE)
	pop { r3-r7 }
	/* restore r8-r11 */
	pop { r0-r3 }
	mov r11, r3
	mov r10, r2
	mov r9, r1
	mov r8, r0
	pop { pc }
#else
	pop {r3-r11, pc}
#endif
	.end
